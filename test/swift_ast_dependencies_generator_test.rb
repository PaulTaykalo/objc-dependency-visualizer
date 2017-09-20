require 'minitest/autorun'
require 'objc_dependency_tree_generator'
require 'sourcekitten_dependencies_generator'

class SwiftAstDependenciesGeneratorTest < Minitest::Test
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert(tree.isEmpty?)
  end

  def test_simple_app_delegate
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/appdelegate.ast'
    )
    tree = generator.build_dependency_tree
    assert(tree.isRegistered?('AppDelegate'))
    assert_equal tree.type('AppDelegate'), DependencyItemType::CLASS
  end

  def test_all_classes
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/complex-file.ast'
    )
    tree = generator.build_dependency_tree
    assert_equal tree.type('Protocol1Impl'), DependencyItemType::CLASS
    assert_equal tree.type('Protocol2Impl'), DependencyItemType::CLASS
    assert_equal tree.type('Class1'), DependencyItemType::CLASS
    assert_equal tree.type('ClassWithFunctions'), DependencyItemType::CLASS
  end

  def test_all_protocols
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/complex-file.ast'
    )
    tree = generator.build_dependency_tree
    assert_equal tree.type('Protocol2'), DependencyItemType::PROTOCOL
    assert_equal tree.type('Protocol1'), DependencyItemType::PROTOCOL
  end

  def test_inheritance
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/complex-file.ast'
    )
    tree = generator.build_dependency_tree
    assert tree.connected?('Protocol1Impl', 'Protocol1')
    assert_equal tree.link_type('Protocol1Impl', 'Protocol1'), DependencyLinkType::INHERITANCE

  end

end
