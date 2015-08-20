# encoding: UTF-8
require 'optparse'
require 'yaml'
require 'json'
require 'objc_dependency_tree_generator_helper'
require 'swift_dependencies_generator'
require 'objc_dependencies_generator'

class ObjCDependencyTreeGenerator

  def initialize(options)
    @options = options
    @options[:derived_data_project_pattern] = '*-*' unless @options[:derived_data_project_pattern]

    @exclusion_prefixes = @options[:exclusion_prefixes] ? @options[:exclusion_prefixes] : 'NS|UI|CA|CG|CI|CF'
    @object_files_directory = @options[:search_directory]
  end

  def self.parse_command_line_options
    options = {}

#Defaults
    options[:derived_data_paths] = ['~/Library/Developer/Xcode/DerivedData', '~/Library/Caches/appCode*/DerivedData']
    options[:project_name] = ''

    parser = OptionParser.new do |o|
      o.separator 'General options:'

      o.on('-p PATH', 'Path to directory where are your .o files were placed by the compiler') { |directory|
        options[:search_directory] = directory
      }
      o.on('-D DERIVED_DATA', 'Path to directory where DerivedData is') { |derived_data|
        options[:derived_data_paths] = [derived_data]
        options[:derived_data_project_pattern] = '*'
      }
      o.on('-s PROJECT_NAME', 'Search project .o files by specified project name') { |project_name|
        options[:project_name] = project_name
      }
      o.on('-t TARGET_NAME', 'Target of project') { |target_name|
        options[:target_name] = target_name
      }
      o.on('-e PREFIXES', "Prefixes of classes those will be exсluded from visualization. \n\t\t\t\t\tNS|UI\n\t\t\t\t\tUI|CA|MF") { |exclusion_prefixes|
        options[:exclusion_prefixes] = exclusion_prefixes
      }

      o.on('-d', '--use-dwarf-info', 'Use DWARF Information also') { |v|
        options[:use_dwarf] = v
      }
      o.on('-w', '--swift-dependencies', 'Generate swift project dependencies') { |v|
        options[:swift_dependencies] = v
      }
      o.on('-f FORMAT', 'Output format. json by default. Possible values are [json-pretty|json|json-var|yaml]') { |f|
        options[:output_format] = f
      }

      o.separator 'Common options:'
      o.on_tail('-h', 'Prints this help') { puts o; exit }
      o.parse!
    end

    options

  end

  def find_dependencies
    if !@options or @options.empty?
      return {}
    end

    unless @object_files_directory
      @object_files_directory =
          find_project_output_directory(@options[:derived_data_paths],
                                        @options[:project_name],
                                        @options[:derived_data_project_pattern],
                                        @options[:target_name])
      return {} unless @object_files_directory
    end

    unless @object_files_directory
      puts parser.help
      exit 1
    end


    links = {}
    links_block = lambda { |source, dest|
      links[source] = {} unless links[source]
      if source != dest and is_valid_dest?(dest, @exclusion_prefixes)
        links[source][dest] = 'set up'
      end
    }

    if @options[:swift_dependencies]
      SwiftDependenciesGenerator.new.generate_dependencies(@object_files_directory, &links_block)
    else
      ObjcDependenciesGenerator.new.generate_dependencies(@object_files_directory, @options[:use_dwarf], &links_block)
    end

    links
  end

  def dependencies_to_s
    links = find_dependencies
    s = ''
    if @options[:output_format] == 'json-var'
      s+= <<-THEEND
   var dependencies =
      THEEND
    end

    json_result = {}
    json_links = []

    links_count = 0
    links.each do |source, dest_hash|
      links_count = links_count + dest_hash.length
      dest_hash.each do |dest, _|
        json_links += [{'source' => source, 'dest' => dest}]
      end
    end
    json_result['links'] = json_links
    json_result['source_files_count'] = links.length
    json_result['links_count'] = links_count


    s = s + JSON.pretty_generate(json_result) if @options[:output_format] == 'json-pretty'
    s = s + json_result.to_json if @options[:output_format] == 'json' || @options[:output_format] == 'json-var'
    s = s + json_result.to_yaml if @options[:output_format] == 'yaml'
    s
  end


end