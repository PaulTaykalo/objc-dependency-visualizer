require 'objc_dependency_tree_generator_helper'
require 'parser/swift_ast_parser'

class SwiftAstDependenciesGenerator

  def initialize(ast_file)
    @ast_file = ast_file
  end

  # @return [DependencyTree]
  def generate_dependencies

    @tree = DependencyTree.new
    @context = []

    @ast_tree = SwiftAST::Parser.new().parse(File.read(@ast_file))
    # @ast_tree.dump
    scan_source_files

    @tree
  end

  def scan_source_files
    classes = @ast_tree.find_nodes("class_decl")
    classes.each { |node| 
      classname = node.parameters.first
      return unless classname
      @tree.register(classname, DependencyItemType::CLASS) 
    }

    protocols = @ast_tree.find_nodes("protocol")
    protocols.each { |node| 
      protoname = node.parameters.first
      return unless protoname
      @tree.register(protoname, DependencyItemType::PROTOCOL) 
    }

    classes.each { |node| 
      classname = node.parameters.first
      register_inheritance(node, classname) if classname
    }

    protocols.each { |node|
      proto_name = node.parameters.first
      register_inheritance(node, proto_name) if proto_name
    }

  end

  def register_inheritance(node, name)
    inheritance = node.parameters.drop_while { |el| el =! "inherits:" }
    inheritance.each { |inh| 
      inh_name = inh.chomp(",")
      @tree.add(name, inh_name, DependencyLinkType::INHERITANCE)
    }

  end  


end
