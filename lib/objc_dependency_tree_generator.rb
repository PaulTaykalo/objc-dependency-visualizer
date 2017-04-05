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
      o.on('-p PATH', '--path', 'Path to directory where are your .o files were placed by the compiler', Array) do |directory|
        options[:search_directories] = Array(options[:search_directories]) | Array(directory)
      end
      o.on('-D DERIVED_DATA', 'Path to directory where DerivedData is') do |derived_data|
        options[:derived_data_paths] = [derived_data]
        options[:derived_data_project_pattern] = '*'
      end
      o.on('-output PROJECT_NAME', 'Search project .o files by specified project name') do |project_name|
        options[:project_name] = project_name
      end
      o.on('-t TARGET_NAME', '--target', 'Target of project', Array) do |target_name|
        options[:target_names] = Array(options[:target_names]) | Array(target_name)
      end
      o.on('-e PREFIXES', "Prefixes of classes those will be exсluded from visualization. \n\t\t\t\t\tNS|UI\n\t\t\t\t\tUI|CA|MF") do |exclusion_prefixes|
        options[:exclusion_prefixes] = exclusion_prefixes
      end

      o.on('-d', '--use-dwarf-info', 'Use DWARF Information also') { |v|
        options[:use_dwarf] = v
      }
      o.on('-w', '--swift-dependencies', 'Generate swift project dependencies') do |v|
        options[:swift_dependencies] = v
      end
      o.on('-k FILENAME', 'Generate dependencies from source kitten output (json)') do |v|
        options[:sourcekitten_dependencies_file] = v
      end
      o.on('-f FORMAT', 'Output format. json by default. Possible values are [dot|json-pretty|json|json-var|yaml]') do |f|
        options[:output_format] = f
      end
      o.on('-o OUTPUT_FILE', '--output', 'target of output') do |f|
        options[:target_file_name] = f
      end

      o.separator 'Common options:'
      o.on_tail('-h', 'Prints this help') do
        puts o
        exit
      end
      o.parse!

    end

    options

  end

  # @return [DependencyTree]
  def find_dependencies
    return {} if !@options || @options.empty?

    links = {}
    links_block = lambda { |source, dest|
      links[source] = {} unless links[source]
      if source != dest and is_valid_dest?(dest, @exclusion_prefixes)
        links[source][dest] = 'set up'
      end
    }

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
      SwiftDependenciesGenerator.new.generate_dependencies(
        @object_files_directories,
        &links_block
      )
    else
      ObjcDependenciesGenerator.new.generate_dependencies(
        @object_files_directories,
        @options[:use_dwarf],
        &links_block
      )
    end

    links
  end

  def build_dependency_tree
    if @options[:sourcekitten_dependencies_file]
      return build_sourcekitten_dependency_tree
    end

    tree = DependencyTree.new
    links = find_dependencies

    links.each do |source, dest_hash|
      tree.register(source)
      dest_hash.each do |dest, _|
        tree.add(source, dest)
      end
    end

    tree
  end

  def build_sourcekitten_dependency_tree
    SourceKittenDependenciesGenerator.new.generate_dependencies(
      @options[:sourcekitten_dependencies_file]
    )
  end

  def dependencies_to_s
    tree = build_dependency_tree
    serializer = TreeSerializer.new(tree)
    output = serializer.serialize(@options[:output_format])

    if @options[:target_file_name]
      target = File.open(@options[:target_file_name], 'w')
      target.write(output.to_s)
    else

      output
    end
  end


end
