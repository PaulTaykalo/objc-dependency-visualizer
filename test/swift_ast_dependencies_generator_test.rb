require 'minitest/autorun'
require 'objc_dependency_tree_generator'
require 'sourcekitten/sourcekitten_dependencies_generator'

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
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/first-file.ast'
    )
    tree = generator.build_dependency_tree
    assert_equal tree.type('Protocol1Impl'), DependencyItemType::CLASS
    assert_equal tree.type('Protocol2Impl'), DependencyItemType::CLASS
    assert_equal tree.type('Class1'), DependencyItemType::CLASS
    assert_equal tree.type('ClassWithFunctions'), DependencyItemType::CLASS
  end

  def test_all_protocols
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/first-file.ast'
    )
    tree = generator.build_dependency_tree
    assert_equal tree.type('Protocol2'), DependencyItemType::PROTOCOL
    assert_equal tree.type('Protocol1'), DependencyItemType::PROTOCOL
  end

  def test_inheritance
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/first-file.ast'
    )
    tree = generator.build_dependency_tree
    assert tree.connected?('Protocol1Impl', 'Protocol1')
    assert_equal tree.link_type('Protocol1Impl', 'Protocol1'), DependencyLinkType::INHERITANCE
    assert_equal tree.link_type('Protocol2Impl', 'Protocol2'), DependencyLinkType::INHERITANCE

  end

  def test_variables_dependency
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/first-file.ast'
    )
    tree = generator.build_dependency_tree
    assert tree.connected?('Class1', 'Protocol1')
    assert tree.connected?('Class1', 'Protocol2')
    assert tree.connected?('Class1', 'Protocol1Impl')
    assert tree.connected?('Class1', 'Protocol2Impl')

    assert_equal tree.link_type('Class1', 'Protocol1'), DependencyLinkType::IVAR
    assert_equal tree.link_type('Class1', 'Protocol2'), DependencyLinkType::IVAR
    assert_equal tree.link_type('Class1', 'Protocol1Impl'), DependencyLinkType::CALL
    assert_equal tree.link_type('Class1', 'Protocol2Impl'), DependencyLinkType::CALL
  end

  def test_function_types_dependency
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/first-file.ast'
    )
    tree = generator.build_dependency_tree
    assert tree.connected?('ClassWithFunctions', 'Protocol1')
    assert_equal tree.link_type('ClassWithFunctions', 'Protocol1'), DependencyLinkType::PARAMETER

    assert tree.connected?('ClassWithFunctions', 'Protocol2')
    assert_equal tree.link_type('ClassWithFunctions', 'Protocol2'), DependencyLinkType::PARAMETER

    assert tree.connected?('ClassWithFunctions', 'Protocol2Impl')
    assert_equal tree.link_type('ClassWithFunctions', 'Protocol2Impl'), DependencyLinkType::CALL

  end  

  def test_generics_dependencies
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ProtocolForGeneric'))
    assert(tree.isRegistered?('ProtocolForGeneric2'))

    assert_nil tree.type('<A : ProtocolForGeneric>'), "Dependency should resolve generics and not take them as declaration"
    assert !tree.isRegistered?('<A : ProtocolForGeneric>'), "Dependency should resolve generics and not take them as declaration"

    assert tree.connected?('GenericClass', 'ProtocolForGeneric')
    assert tree.connected?('GenericClass2', 'ProtocolForGeneric')
    assert tree.connected?('GenericClass2', 'ProtocolForGeneric2')

    assert tree.connected?('GenericClass3', 'ProtocolForGeneric')
    assert tree.connected?('GenericClass3', 'ProtocolForGeneric2')

    assert tree.connected?('GenericClassWithProp', 'ProtocolForGeneric')
    
  end  

  def test_generics_usages_should_not_be_registered
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ProtocolForGeneric'))
    assert(tree.isRegistered?('ProtocolForGeneric2'))
    assert(!tree.isRegistered?('E'), "Parser should skip regisestering generic parameters")

    assert tree.connected?('GenericClassWithProp', 'ProtocolForGeneric')
    assert !tree.connected?('GenericClassWithProp', 'E'), "Parser should skip regisestering generic parameters"

    assert(!tree.isRegistered?('GenericClassWithProp<E>'))

  end  

  def test_generic_functions_in_protocols
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ProtocolWithGenericFunction'))
    assert(!tree.isRegistered?('F'), "Parser should skip regisestering generic parameters")
    assert(!tree.isRegistered?('G'), "Parser should skip regisestering generic parameters")
    assert(!tree.isRegistered?('N'), "Parser should skip regisestering generic parameters")

    assert(tree.isRegistered?('ClassWithGenericFunction'))
    assert(!tree.isRegistered?('J'), "Parser should skip regisestering generic parameters")

    assert(tree.isRegistered?('ProtocolWithGenericFunctionToImplement'))
    assert(!tree.isRegistered?('K'), "Parser should skip regisestering generic parameters")

  end 

  def test_generic_functions_restrictions
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ProtocolWithGenericFunction'))
    assert tree.connected?('ProtocolWithGenericFunction', 'ProtocolForGeneric2'), "Parser should get types from generic restrictions of type `func a<P: Type>()`"

  end  

  def test_extesion_dependencies
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ClassWithGenericFunction'))
    assert(tree.isRegistered?('ProtocolWithGenericFunctionToImplement'))
    assert tree.connected?('ClassWithGenericFunction', 'ProtocolWithGenericFunctionToImplement'), "Parser should get types from extension inheritance `extension C: Type`"
    assert(!tree.isRegistered?('M'), "Parser should skip regisestering generic parameters")

  end  

  def test_typealias_dependencies
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ClassWithTypeaLias'))
    assert(tree.isRegistered?('ProtocolForTypeAlias'))
    assert(!tree.isRegistered?('H'), "Parser should skip regisestering typealias parameters")
    assert tree.connected?('ClassWithTypeaLias', 'ProtocolForTypeAlias'), "Parser should get types from typealiases `typealias H = Protocol`"

  end  

  def test_typealias_dependencies_in_params
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/second-file.ast'
      )
    tree = generator.build_dependency_tree

    assert(tree.isRegistered?('ClassWithTypeaLiasInFunctionParams'))
    assert(tree.isRegistered?('ProtocolForTypeAlias'))
    assert(!tree.isRegistered?('I'), "Parser should skip regisestering typealias parameters")
    assert tree.connected?('ClassWithTypeaLiasInFunctionParams', 'ProtocolForTypeAlias'), "Parser should get types from typealiases `typealias H = Protocol`"

  end  

  def test_realwordl_example
    generator = DependencyTreeGenerator.new(
      swift_ast_dump_file: './test/fixtures/swift-dump-ast/cell-file.ast'
      )
    tree = generator.build_dependency_tree
    assert tree, "Parser should be able to parse real-world examples"
  end  
  


end
