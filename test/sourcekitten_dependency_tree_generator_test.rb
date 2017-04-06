require 'test/unit'
require 'test/unit/assertions'
require 'objc_dependency_tree_generator'
require 'sourcekitten_dependencies_generator'

class SourceKittenDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert_true(tree.isEmpty?)
  end

  def test_simple_objects
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.isRegistered?('MainClass'))
    assert_true(tree.isRegistered?('SubclassOfSubclass'))
    assert_true(tree.isRegistered?('Subclass'))

    # types check
    assert_equal(tree.type('AppDelegate'), DependencyItemType::CLASS)
    assert_equal(tree.type('MainClass'), DependencyItemType::CLASS)
    assert_equal(tree.type('SubclassOfSubclass'), DependencyItemType::CLASS)
    assert_equal(tree.type('Subclass'), DependencyItemType::CLASS)
  end


  def test_simple_inheritance
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.connected?('Subclass', 'MainClass'))
    assert_true(tree.connected?('SubclassOfSubclass', 'Subclass'))
    assert_true(tree.connected?('SubclassOfSubclass', 'AwesomeProtocol'))
    assert_true(tree.connected?('SubProtocol', 'AwesomeProtocol'))
    assert_true(tree.connected?('SubclassOfMainClass', 'MainClass'))
    assert_true(tree.connected?('SubclassOfMainClass', 'SubProtocol'))

    assert_true(tree.isRegistered?('AwesomeProtocol'))
    assert_true(tree.isRegistered?('SubProtocol'))

    # types check
    assert_equal(tree.type('AwesomeProtocol'), DependencyItemType::PROTOCOL)
    assert_equal(tree.type('SubProtocol'), DependencyItemType::PROTOCOL)

  end

  def test_extensions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('ProtocolToExtend'))
    assert_true(tree.connected?('MainClass', 'ProtocolToExtend'))

    # types check
    assert_equal(tree.type('ProtocolToExtend'), DependencyItemType::PROTOCOL)
    assert_equal(tree.type('MainClass'), DependencyItemType::CLASS)

  end

  def test_structs
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('SimpleStruct'))
    assert_true(tree.connected?('StructWithProtocols', 'ProtocolToExtend'))
    assert_true(tree.connected?('StructWithProtocols', 'AwesomeProtocol'))

    # types check
    assert_equal(tree.type('StructWithProtocols'), DependencyItemType::STRUCTURE)

  end

  def test_interfile_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('SecondClass'))
    assert_true(tree.isRegistered?('SecondClassProtocol'))
    assert_true(tree.connected?('SecondClass', 'MainClass'))
    assert_true(tree.connected?('SecondClass', 'SecondClassProtocol'))
    assert_true(tree.connected?('SecondClass', 'AwesomeProtocol'))
  end


end