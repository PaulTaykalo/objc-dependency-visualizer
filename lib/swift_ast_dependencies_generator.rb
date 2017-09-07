require 'objc_dependency_tree_generator_helper'

class SwiftAstDependenciesGenerator

  def initialize(ast_file)
    @ast_file = ast_file
  end

  # @return [DependencyTree]
  def generate_dependencies

    @tree = DependencyTree.new
    @context = []

    file = File.read(@ast_file)

    @scanner = StringScanner.new(file)
    scan_source_files

    @tree
  end

  def scan_source_files
    token = scan_next_token
    if token == "source_file"
      @tree.register("AppDelegate")
    end
  end

  def scan_next_token
    @scanner.scan(/\(/)
    @scanner.scan(/\w+/)
  end


end
