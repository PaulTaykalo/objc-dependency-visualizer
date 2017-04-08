require 'test/unit'
require 'test/unit/assertions'
require 'objc_dependency_tree_generator'
require 'sourcekitten_dependencies_generator'

class SourceKittenDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert(tree.isEmpty?)
  end

  def test_simple_objects
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.isRegistered?('MainClass'))
    assert(tree.isRegistered?('SubclassOfSubclass'))
    assert(tree.isRegistered?('Subclass'))

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
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.connected?('Subclass', 'MainClass'))
    assert(tree.connected?('SubclassOfSubclass', 'Subclass'))
    assert(tree.connected?('SubclassOfSubclass', 'AwesomeProtocol'))
    assert(tree.connected?('SubProtocol', 'AwesomeProtocol'))
    assert(tree.connected?('SubclassOfMainClass', 'MainClass'))
    assert(tree.connected?('SubclassOfMainClass', 'SubProtocol'))

    assert(tree.isRegistered?('AwesomeProtocol'))
    assert(tree.isRegistered?('SubProtocol'))

    # types check
    assert_equal(tree.type('AwesomeProtocol'), DependencyItemType::PROTOCOL)
    assert_equal(tree.type('SubProtocol'), DependencyItemType::PROTOCOL)

  end

  def test_extensions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ProtocolToExtend'))
    assert(tree.connected?('MainClass', 'ProtocolToExtend'))

    # types check
    assert_equal(tree.type('ProtocolToExtend'), DependencyItemType::PROTOCOL)
    assert_equal(tree.type('MainClass'), DependencyItemType::CLASS)

  end

  def test_structs
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('SimpleStruct'))
    assert(tree.connected?('StructWithProtocols', 'ProtocolToExtend'))
    assert(tree.connected?('StructWithProtocols', 'AwesomeProtocol'))

    # types check
    assert_equal(tree.type('StructWithProtocols'), DependencyItemType::STRUCTURE)

  end

  def test_interfile_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('SecondClass'))
    assert(tree.isRegistered?('SecondClassProtocol'))
    assert(tree.connected?('SecondClass', 'MainClass'))
    assert(tree.connected?('SecondClass', 'SecondClassProtocol'))
    assert(tree.connected?('SecondClass', 'AwesomeProtocol'))
  end

  def test_properties_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('Class1'))
    assert(tree.isRegistered?('Protocol1'))
    assert(tree.isRegistered?('Protocol1Impl'))
    assert(tree.connected?('Class1', 'Protocol1'))
  end

  def test_properties_optional_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('Class1'))
    assert(tree.isRegistered?('Protocol2'))
    assert(tree.isRegistered?('Protocol2Impl'))
    assert(tree.connected?('Class1', 'Protocol2'))
  end

  def test_exclude_system_types
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('Class1'))
    assert(tree.isRegistered?('Protocol2'))
    assert(!tree.connected?('Class1', 'Int'))
    assert(!tree.connected?('Class1', 'Double'))
    assert(!tree.connected?('Class1', 'String'))
    assert(!tree.connected?('Class1', 'Any'))
  end


  def test_func_parameters_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithFunctions'))
    assert(tree.connected?('ClassWithFunctions', 'Protocol1'))
  end

  def test_func_return_dependencies
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithFunctions'))
    assert(tree.connected?('ClassWithFunctions', 'Protocol2'))
  end


end