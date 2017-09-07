require 'minitest/autorun'
require 'objc_dependency_tree_generator'
require 'sourcekitten_dependencies_generator'

class SwiftAstDependenciesGeneratorTest < Minitest::Test
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert(tree.isEmpty?)
  end

  def test_all_classes_and_protocols
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/complex-file.ast'
    )
    tree = generator.build_dependency_tree
    assert(tree.isRegistered?('AppDelegate'))
  end
end
