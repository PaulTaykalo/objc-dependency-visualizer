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

  def test_ignore_generic_parameters
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('GenericClass'))
    assert(tree.isRegistered?('ProtocolForGeneric'))
    assert(tree.connected?('GenericClass', 'ProtocolForGeneric'))
    assert(!tree.isRegistered?('A'))
    assert(!tree.connected?('GenericClass', 'A'))
  end

  def test_ignore_generic_parameters_with_multiple_protocols
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('GenericClass2'))
    assert(tree.isRegistered?('ProtocolForGeneric2'))
    assert(tree.connected?('GenericClass2', 'ProtocolForGeneric'))
    assert(tree.connected?('GenericClass2', 'ProtocolForGeneric2'))
    assert(!tree.isRegistered?('B'))
    assert(!tree.connected?('GenericClass2', 'B'))
  end

  def test_ignore_generic_multiple_parameters
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('GenericClass3'))
    assert(tree.connected?('GenericClass3', 'ProtocolForGeneric'))
    assert(tree.connected?('GenericClass3', 'ProtocolForGeneric2'))
    assert(!tree.isRegistered?('C'))
    assert(!tree.isRegistered?('D'))
    assert(!tree.connected?('GenericClass3', 'C'))
    assert(!tree.connected?('GenericClass3', 'D'))
  end

  def test_ignore_generic_parameters_in_variables
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('GenericClassWithProp'))
    assert(!tree.isRegistered?('E'))
    assert(!tree.connected?('GenericClassWithProp', 'E'))
  end

  def test_another_module_inheritacne
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.connected?('AppDelegate', 'UIResponder'))
    assert(tree.connected?('AppDelegate', 'UIApplicationDelegate'))
    assert(tree.connected?('TheButton', 'UIButton'))
    assert_equal(tree.type('UIResponder'), DependencyItemType::CLASS)
    assert_equal(tree.type('UIApplicationDelegate'), DependencyItemType::PROTOCOL)
    assert_equal(tree.type('UIButton'), DependencyItemType::CLASS)

  end

  def test_ignore_parameters_in_generic_functions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ProtocolWithGenericFunction'))
    assert(!tree.isRegistered?('F'))
    assert(!tree.isRegistered?('N'))
  end

  def test_include_parameters_in_generic_functions_requirements
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ProtocolWithGenericFunction'))
    assert(!tree.isRegistered?('G'))
    assert(tree.connected?('ProtocolWithGenericFunction', 'ProtocolForGeneric2'))
    assert(!tree.connected?('ProtocolWithGenericFunction', 'G'))
  end

  def test_ignore_typealiases
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithTypeaLias'))
    assert(!tree.isRegistered?('H'))
  end

  def test_register_typealiases_types
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.connected?('ClassWithTypeaLias', 'ProtocolForTypeAlias'))
  end

  def test_ignore_typealiases_in_functions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithTypeaLiasInFunctionParams'))
    assert(!tree.isRegistered?('I'))
  end

  def test_ignore_generics_in_functions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithGenericFunction'))
    assert(!tree.isRegistered?('J'))
  end

  def test_ignore_generics_in_functions_in_extensions
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithGenericFunction'))
    assert(!tree.isRegistered?('K'))
  end

  def test_ignore_generics_in_functions_in_extensions_by_protocol_impl
    generator = DependencyTreeGenerator.new(
      sourcekitten_dependencies_file: './test/fixtures/sourcekitten-with-properties/sourcekitten.json',
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('ClassWithGenericFunction'))
    assert(!tree.isRegistered?('L'))
    assert(!tree.isRegistered?('M'))
    assert(tree.connected?('ClassWithGenericFunction', 'ProtocolWithGenericFunctionToImplement'))

  end


end