# encoding: UTF-8
require 'optparse'
require 'yaml'
require 'json'
require 'objc_dependency_tree_generator_helper'
require 'swift_dependencies_generator'
require 'objc_dependencies_generator'
require 'sourcekitten_dependencies_generator'
require 'dependency_tree'
require 'tree_serializer'

class DependencyTreeGenerator

  def initialize(options)
    @options = options
    @options[:derived_data_project_pattern] = '*-*' unless @options[:derived_data_project_pattern]

    @exclusion_prefixes = @options[:exclusion_prefixes] ? @options[:exclusion_prefixes] : 'NS|UI|CA|CG|CI|CF'
    @object_files_directories = @options[:search_directories]
  end

  def self.parse_command_line_options
    options = {}

    # Defaults
    options[:derived_data_paths] = ['~/Library/Developer/Xcode/DerivedData', '~/Library/Caches/appCode*/DerivedData']
    options[:project_name] = ''
    options[:output_format] = 'json'


    OptionParser.new do |o|
      o.separator 'General options:'
      o.on('-p PATH', '--path', 'Path to directory where are your .o files were placed by the compiler', Array) { |directory|
        options[:search_directories] = Array(options[:search_directories]) | Array(directory)
      }
      o.on('-D DERIVED_DATA', 'Path to directory where DerivedData is') { |derived_data|
        options[:derived_data_paths] = [derived_data]
        options[:derived_data_project_pattern] = '*'
      }
      o.on('-s PROJECT_NAME', 'Search project .o files by specified project name') { |project_name|
        options[:project_name] = project_name
      }
      o.on('-t TARGET_NAME', '--target' 'Target of project', Array) { |target_name|
        options[:target_names] = Array(options[:target_names]) | Array(target_name)
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
      o.on('-k FILENAME', 'Generate dependencies from source kitten output (json)') { |v|
        options[:sourcekitten_dependencies_file] = v
      }
      o.on('-f FORMAT', 'Output format. json by default. Possible values are [dot|json-pretty|json|json-var|yaml]') { |f|
        options[:output_format] = f
      }
      o.on('-o OUTPUT_FILE', '--output', 'target of output') { |f|
        options[:target_file_name] = f
      }

      o.separator 'Common options:'
      o.on_tail('-h', 'Prints this help') { puts o; exit }
      o.parse!

    end

    options

  end

  def find_dependencies
    return {} if !@options || @options.empty?

    links = {}
    links_block = lambda { |source, dest|
      links[source] = {} unless links[source]
      if source != dest and is_valid_dest?(dest, @exclusion_prefixes)
        links[source][dest] = 'set up'
      end
    }

    if @options[:sourcekitten_dependencies_file]
      SourceKittenDependenciesGenerator.new.generate_dependencies(@options[:sourcekitten_dependencies_file], &links_block)
      return links
    end


    unless @object_files_directories
      @object_files_directories = find_project_output_directory(
          @options[:derived_data_paths],
          @options[:project_name],
          @options[:derived_data_project_pattern],
          @options[:target_names]
      )
      return {} unless @object_files_directories
    end

    unless @object_files_directories
      puts parser.help
      exit 1
    end


    if @options[:swift_dependencies]
      SwiftDependenciesGenerator.new.generate_dependencies(@object_files_directories, &links_block)
    else
      ObjcDependenciesGenerator.new.generate_dependencies(@object_files_directories, @options[:use_dwarf], &links_block)
    end

    links
  end

  def dependency_tree
    tree = DependencyTree.new
    links = find_dependencies

    links.each do |source, dest_hash|
      dest_hash.each do |dest, _|
        tree.add(source, dest)
      end
    end

    tree
  end

  def dependencies_to_s
    tree = dependency_tree
    serializer = TreeSerializer.new(tree)
    s = serializer.serialize(@options[:output_format])
    if @options[:target_file_name]
      target = File.open(@options[:target_file_name], 'w')
      target.write("#{s}")
    else
      s
    end
  end


end
