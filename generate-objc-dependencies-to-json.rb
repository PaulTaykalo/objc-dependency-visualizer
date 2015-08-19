#!/usr/bin/ruby

require 'optparse'
require 'yaml'

options = {}

#Defaults
options[:exclusion_prefixes] = "NS|UI|CA|CG|CI|CF"
options[:derived_data_paths] = ["~/Library/Developer/Xcode/DerivedData", "~/Library/Caches/appCode*/DerivedData"]
options[:project_name] = ""
derived_data_project_pattern = "*-*"


parser = OptionParser.new do |o|
  o.separator "General options:"

  o.on('-p PATH', "Path to directory where are your .o files were placed by the compiler") { |directory|
    options[:search_directory] = directory
  }
  o.on('-D DERIVED_DATA', "Path to directory where DerivedData is") { |derived_data|
    options[:derived_data_paths] = [derived_data]
    derived_data_project_pattern = "*"
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

unless options[:search_directory]
  paths = []

  # looking for derived data
  options[:derived_data_paths].each do |derived_data_path|
    IO.popen("find #{derived_data_path} -name \"#{options[:project_name]}#{derived_data_project_pattern}\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f|
      f.each do |line|
        paths << line
      end
    }
  end


  $stderr.puts "There were #{paths.length} directories found"
  if paths.empty?
    $stderr.puts "Cannot find projects that starts with '#{options[:project_name]}'"
    exit 1
  end

  filtered_by_target_paths = paths

  if options[:target_name]
    filtered_by_target_paths = paths.find_all { |path| /#{options[:target_name]}[^\.]*\.build\/Objects-normal/.match path }
    $stderr.puts "After target filtration there is #{filtered_by_target_paths.length} directories left"
    if paths.empty?
      $stderr.puts "Cannot find projects that starts with '#{options[:project_name]}'' and has target name that starts with '#{options[:target_name]}'"
      exit 1
    end
  end

  paths_sorted_by_time = filtered_by_target_paths.sort_by do |f|
    File.ctime(f.chomp)
  end

  last_modified_dir = paths_sorted_by_time.last.chomp
  $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"

  options[:search_directory] = last_modified_dir
end

unless options[:search_directory]
  puts parser.help
  exit 1
end


links = {}

def is_primitive_swift_type?(dest)
  /^(Int|Int32|Int64|Int16|Int8|UInt|UInt32|UInt64|UInt16|UInt8|String|Character|Bool|Float|Double|Dictionary|Array|Set|AnyObject|Void)$/.match(dest) != nil
end

def is_filtered_swift_type?(dest)
  /(ClusterType|ScalarType|LiteralType)$/.match(dest) != nil #or /^([a-z])/.match(dependency) != nil
end


def can_be_used_as_destination(dest, exclusion_prefixs)
  /^(#{exclusion_prefixs})/.match(dest) == nil and /^\w/.match(dest) != nil and !is_primitive_swift_type?(dest) and !is_filtered_swift_type?(dest)
end

def add_dependency_link(links, source, dest)
  if source != dest and dest != 'BOOL'
    destinations = links[source] ? links[source] : (links[source] = {})
    destinations[dest] = 'set up'
  end
end

if options[:swift_dependencies]
  # This thing need to be commented :) It's removes too many connections
  # YAML.add_domain_type("", "private") { |type, val|
  #   'AnyObject'
  # }
  Dir.glob("#{options[:search_directory]}/*.swiftdeps") do |swift_deps_file|
    # puts swift_deps_file
    swiftdeps = YAML.load_file(swift_deps_file)

    declared_classes = swiftdeps[:provides]
    dependencies = swiftdeps[:'top-level']

    if declared_classes
      if declared_classes.length == 1
        source = declared_classes.first
        dependencies.each do |dependency|
          if can_be_used_as_destination(dependency, options[:exclusion_prefixes])
            add_dependency_link(links, source, dependency)
          end
        end
      else

        # Linking all classes as dependent items of this file
        filename = '< ' + File.basename(swift_deps_file, '.swiftdeps') +' >'
        declared_classes.each do |clz|
          add_dependency_link(links, clz, filename)
        end

        # Linking all dependencies to to
        dependencies.each do |dependency|
          if can_be_used_as_destination(dependency, options[:exclusion_prefixes]) and not declared_classes.include?(dependency)
            add_dependency_link(links, filename, dependency)
          end
        end
      end
    end
  end
else
  #Searching all the .o files and showing its information through nm call
  IO.popen("find \"#{options[:search_directory]}\" -name \"*.o\" -exec  /usr/bin/nm -o {} \\;") { |f|
    f.each do |symbol_name_string|

      # Gathering only OBC_CLASSES
      if symbol_name_string =~ /_OBJC_CLASS_\$_/

        # Excluding base frameworks prefixes
        unless symbol_name_string =~ /_OBJC_CLASS_\$_(#{options[:exclusion_prefixes]})/

          #Capturing filename (We'll treat that as a source)
          #And dependency (We'll treat it as a destination)
          source, dest = /[^\w]*([^\.\/]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(symbol_name_string)[1, 2]
          add_dependency_link(links, source, dest)
        end
      end
    end
  }

  if options[:use_dwarf]

    # Search files again
    IO.popen("find \"#{options[:search_directory]}\" -name \"*.o\"") do |f|
      f.each do |object_file_path|

        # puts "Running dwarfdump #{object_file_path} | grep -A1 TAG_pointer_type"
        source = /.*\/(.+)\.o/.match(object_file_path)[1]

        IO.popen("dwarfdump #{object_file_path.strip} | grep -A1 TAG_pointer_type") do |fd|
          fd.each do |type_definition|
            # Finding the name in types
            # AT_type( {0x00000456} ( objc_object ) )
            name = /.*?AT_type\(\s\{.*?\}.*\(\s((function|const)\s)?([A-Z][^\)]+?)\*?\s\).*/.match(type_definition)
            if name != nil
              dest = name[3]
              if can_be_used_as_destination(dest, options[:exclusion_prefixes])
                add_dependency_link(links, source, dest)
              end
            end
          end
        end
      end
    end
  end
end

#Header
puts <<-THEEND
   var dependencies = {
   	links:
   	  [
THEEND

sources_count = links.length
links_count = 0
links.each do |source, dest_hash|
  links_count = links_count + dest_hash.length
  dest_hash.each do |dest, _|
    puts "            { \"source\" : \"#{source}\", \"dependency\" : \"#{dest}\" },"
  end
end


puts <<-THEEND
         ],
     "source_files_count":#{sources_count},
     "links_count":#{links_count},
    }
  ;
THEEND

