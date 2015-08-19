# encoding: UTF-8
require 'optparse'
require 'yaml'

class ObjCDependencyTreeGenerator

  def initialize(options)
    @options = options
    @options[:exclusion_prefixes] = "NS|UI|CA|CG|CI|CF" unless @options[:exclusion_prefixes]
    @options[:derived_data_project_pattern] =  "*-*" unless @options[:derived_data_project_pattern]
  end

  def self.parse_command_line_options
    options = {}

#Defaults
    options[:exclusion_prefixes] = "NS|UI|CA|CG|CI|CF"
    options[:derived_data_paths] = ["~/Library/Developer/Xcode/DerivedData", "~/Library/Caches/appCode*/DerivedData"]
    options[:project_name] = ""
    options[:derived_data_project_pattern] = "*-*"


    parser = OptionParser.new do |o|
      o.separator "General options:"

      o.on('-p PATH', "Path to directory where are your .o files were placed by the compiler") { |directory|
        options[:search_directory] = directory
      }
      o.on('-D DERIVED_DATA', "Path to directory where DerivedData is") { |derived_data|
        options[:derived_data_paths] = [derived_data]
        options[:derived_data_project_pattern] = "*"
      }
      o.on('-s PROJECT_NAME', "Search project .o files by specified project name") { |project_name|
        options[:project_name] = project_name
      }
      o.on('-t TARGET_NAME', "Target of project") { |target_name|
        options[:target_name] = target_name
      }
      o.on('-e PREFIXES', "Prefixes of classes those will be exсluded from visualization. \n\t\t\t\t\tNS|UI\n\t\t\t\t\tUI|CA|MF") { |exclusion_prefixes|
        options[:exclusion_prefixes] = exclusion_prefixes
      }

      o.on("-d", "--use-dwarf-info", "Use DWARF Information also") { |v|
        options[:use_dwarf] = v
      }
      o.on("-w", "--swift-dependencies", "Generate swift project dependencies") { |v|
        options[:swift_dependencies] = v
      }


      o.separator "Common options:"
      o.on_tail('-h', "Prints this help") { puts o; exit }
      o.parse!
    end

    options

  end

  def find_dependencies
    if !@options or @options.empty?
      return {}
    end

    if !@options[:search_directory]
      unless @options[:derived_data_paths]
        return {}
      end
      paths = []

      # looking for derived data
      @options[:derived_data_paths].each do |derived_data_path|
        IO.popen("find #{derived_data_path} -depth 1 -name \"#{@options[:project_name]}#{@options[:derived_data_project_pattern]}\" -type d  -exec find {} -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" -type d \\; ") { |f|
          f.each do |line|
            paths << line
          end
        }
      end


      $stderr.puts "There were #{paths.length} directories found"
      if paths.empty?
        $stderr.puts "Cannot find projects that starts with '#{@options[:project_name]}'"
        exit 1
      end

      filtered_by_target_paths = paths

      if @options[:target_name]
        filtered_by_target_paths = paths.find_all { |path| /#{@options[:target_name]}[^\.]*\.build\/Objects-normal/.match path }
        $stderr.puts "After target filtration there is #{filtered_by_target_paths.length} directories left"
        if paths.empty?
          $stderr.puts "Cannot find projects that starts with '#{@options[:project_name]}'' and has target name that starts with '#{@options[:target_name]}'"
          exit 1
        end
      end

      paths_sorted_by_time = filtered_by_target_paths.sort_by { |f|
        File.ctime(f.chomp)
      }

      last_modified_dir = paths_sorted_by_time.last.chomp
      $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"

      @options[:search_directory] = last_modified_dir
    end

    if !@options[:search_directory]
      puts parser.help
      exit 1
    end


#Header
    links = {}

    def is_primitive_swift_type?(dest)
      /^(Int|Int32|Int64|Int16|Int8|UInt|UInt32|UInt64|UInt16|UInt8|String|Character|Bool|Float|Double|Dictionary|Array|Set|AnyObject|Void)$/.match(dest) != nil
    end

    def is_filtered_swift_type?(dest)
      /(ClusterType|ScalarType|LiteralType)$/.match(dest) != nil #or /^([a-z])/.match(dest) != nil
    end


    def can_be_used_as_destination(dest, exclusion_prefixs)
      /^(#{exclusion_prefixs})/.match(dest) == nil and /^\w/.match(dest) != nil and !is_primitive_swift_type?(dest) and !is_filtered_swift_type?(dest)
    end

    if @options[:swift_dependencies]
      # This thing need to be commented :) It's removes too many connections
      # YAML.add_domain_type("", "private") { |type, val|
      #   'AnyObject'
      # }
      Dir.glob("#{@options[:search_directory]}/*.swiftdeps") do |my_text_file|
        # puts my_text_file
        swiftdeps = YAML.load_file(my_text_file)
        if swiftdeps["provides"] && swiftdeps["provides"].length == 1
          swiftdeps["provides"].each { |source|
            destinations = links[source] ? links[source] : (links[source] = {})
            swiftdeps["top-level"].each { |unparseddest|
              # puts unparseddest
              dest = unparseddest
              if can_be_used_as_destination(dest, @options[:exclusion_prefixes])
                destinations[dest] = "set up"
              end
            }
          }
        elsif swiftdeps["provides"]

          classes_declared_in_file = swiftdeps["provides"]

          filename = '< ' + File.basename(my_text_file, ".swiftdeps") +' >'
          swiftdeps["provides"].each { |source|
            destinations = links[source] ? links[source] : (links[source] = {})
            destinations[filename] = "set up"
          }

          source = filename
          destinations = links[source] ? links[source] : (links[source] = {})
          swiftdeps["top-level"].each { |unparseddest|
            # puts unparseddest
            dest = unparseddest
            if can_be_used_as_destination(dest, @options[:exclusion_prefixes]) and not classes_declared_in_file.include?(dest)
              destinations[dest] = "set up"
            end
          }

        end
      end
    else
      #Searching all the .o files and showing its information through nm call
      IO.popen("find \"#{@options[:search_directory]}\" -name \"*.o\" -exec  /usr/bin/nm -o {} \\;") { |f|
        f.each do |line|

          # Gathering only OBC_CLASSES
          match = /_OBJC_CLASS_\$_/.match line

          if match != nil
            exclusion_match = /_OBJC_CLASS_\$_(#{@options[:exclusion_prefixes]})/.match line

            # Excluding base frameworks prefixes
            if exclusion_match == nil

              #Capturing filename (We'll think that this is source)
              #And dependency (We'll think that this is the destination)

              source, dest = /[^\w]*([^\.\/]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(line)[1, 2]
              if source != dest
                destinations = links[source] ? links[source] : (links[source] = {})
                destinations[dest] = "set up"
              end
            end
          end
        end
      }

      if @options[:use_dwarf]

        # Search files again
        IO.popen("find \"#{@options[:search_directory]}\" -name \"*.o\"") { |f|
          f.each do |line|

            # puts "Running dwarfdump \"#{line}\" | grep -A1 TAG_pointer_type"
            source = /.*\/(.+)\.o/.match(line)[1]
            destinations = links[source] ? links[source] : (links[source] = {})
            IO.popen("dwarfdump \"#{line.strip}\" | grep -A1 TAG_pointer_type") { |fd|
              fd.each do |line2|
                # Finding the name in types
                # AT_type( {0x00000456} ( objc_object ) )
                name = /.*?AT_type\(\s\{.*?\}.*\(\s((function|const)\s)?([A-Z][^\)]+?)\*?\s\).*/.match(line2)
                if name != nil
                  dest = name[3]
                  if can_be_used_as_destination(dest, @options[:exclusion_prefixes])
                    if source != dest and dest != "BOOL"
                      destinations[dest] = "set up"
                    end
                  end
                end
              end
            }
          end
        }
      end
    end

    links
  end

  def dependencies_to_s
    links = find_dependencies
    s = <<-THEEND
   var dependencies = {
   	links:
   	  [
    THEEND


    sources_count = links.length
    links_count = 0
    links.each do |source, dest_hash|
      links_count = links_count + dest_hash.length
      dest_hash.each do |dest, _|
        s += "            { \"source\" : \"#{source}\", \"dest\" : \"#{dest}\" },\n"
      end
    end


    s += <<-THEEND
         ],
     "source_files_count":#{sources_count},
     "links_count":#{links_count},
    }
  ;
    THEEND
    s
  end


end