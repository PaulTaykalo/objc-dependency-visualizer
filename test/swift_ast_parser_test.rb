require 'minitest/autorun'
require 'parser/swift_ast_parser'

class SwiftAstParserTest < Minitest::Test

  def test_simple_objects
    node = SwiftAST::Node.new("name")
    assert node != nil, "it should be able to create simple node"
    assert_equal node.name, "name"

    assert SwiftAST::Parser.new != nil, "Parser should be created!"

  end  

  def test_simple_node_parse
    parser = SwiftAST::Parser.new
    ast = parser.parse("(hello )")
    assert ast != nil, "Parser should return ast1"
    assert_kind_of SwiftAST::Node, ast, "Parser should have correct root node"
  end  

  def test_simple_node_parse_name
    ast = SwiftAST::Parser.new.parse("(hello )")
    assert_equal ast.name, "hello"
  end  

  def test_simple_node_parameters
    ast = SwiftAST::Parser.new.parse("(hello one)")
    assert_equal ast.name, "hello"
    assert_equal ast.parameters, ["one"]
  end  

  def test_multiple_node_parameters
    ast = SwiftAST::Parser.new.parse("(hello one two)")
    assert_equal ast.name, "hello"
    assert_equal ast.parameters, ["one", "two"]
  end  

  def test_multiple_string_parameters
    ast = SwiftAST::Parser.new.parse("(hello 'one' \"two\")")
    assert_equal ast.name, "hello"
    assert_equal ast.parameters, ["one", "two"]

  end  

  def test_custom_node_with_assignment
    ast = SwiftAST::Parser.new.parse("(assignment weather=cool temperature=123")
    assert_equal ast.name, "assignment"
    assert_equal ast.parameters, ["weather=cool", "temperature=123"]
  end  

  def test_custom_node_paramters
    ast = SwiftAST::Parser.new.parse("(hello \"Protocol1\" <Self : Protocol1> interface type='Protocol1.Protocol' access=internal @_fixed_layout requirement signature=<Self>)")
    assert_equal ast.name, "hello"
    assert_equal ast.parameters, ["Protocol1", "<Self : Protocol1>", "interface", "type='Protocol1.Protocol'", "access=internal", "@_fixed_layout", "requirement", "signature=<Self>" ] 
  end  

  def test_node_filetype_parameter
    ast = SwiftAST::Parser.new.parse("(component id='Protocol1' bind=SourcekittenWithComplexDependencies.(file).Protocol1@/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:12:10)")
    assert_equal ast.name, "component"
    assert_equal ast.parameters, ["id='Protocol1'", "bind=SourcekittenWithComplexDependencies.(file).Protocol1@/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:12:10" ] 
  end  

  def test_node_filetype_parameter2
    ast = SwiftAST::Parser.new.parse("(component id='Protocol1' bind=SourcekittenWithComplexDependencies.(file).Protocol1.<anonymous>.@/Users/paultaykalo/Projects/A.swift:12:10)")
    assert_equal ast.name, "component"
    assert_equal ast.parameters, ["id='Protocol1'", "bind=SourcekittenWithComplexDependencies.(file).Protocol1.<anonymous>.@/Users/paultaykalo/Projects/A.swift:12:10"]
  end  

  def test_node_range_parameter
    ast = SwiftAST::Parser.new.parse("(constructor_ref_call_expr implicit type='(_MaxBuiltinIntegerType) -> Int' location=/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:23:22 range=[/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:23:22 - line:23:22] nothrow)")
    assert_equal ast.name, "constructor_ref_call_expr"
    assert_equal ast.parameters, ["implicit", "type='(_MaxBuiltinIntegerType) -> Int'", "location=/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:23:22", "range=[/Users/paultaykalo/Projects/objc-dependency-visualizer/test/fixtures/sourcekitten-with-properties/SourcekittenExample/FirstFile.swift:23:22 - line:23:22]", "nothrow"]
  end  

  def test_node_builtin_literal
    ast = SwiftAST::Parser.new.parse("(constructor_ref_call_expr arg_labels=_builtinBooleanLiteral:)")
    assert_equal ast.name, "constructor_ref_call_expr"
    assert_equal ast.parameters, ["arg_labels=_builtinBooleanLiteral:"]
  end  

  def test_comma_parsing
    ast = SwiftAST::Parser.new.parse("(constructor_ref_call_expr inherits: UIResponder, UIApplicationDelegate)")
    assert_equal ast.name, "constructor_ref_call_expr"
    assert_equal ast.parameters, ["inherits:", "UIResponder,", "UIApplicationDelegate"]
  end  

  def test_nilliteral_parameter_parsing
    ast = SwiftAST::Parser.new.parse("(declref_expr implicit type='(Optional<UIWindow>.Type) -> (()) -> Optional<UIWindow>' decl=Swift.(file).Optional.init(nilLiteral:) [with UIWindow] function_ref=single)
")
    assert_equal ast.name, "declref_expr"
    assert_equal ast.parameters, ["implicit", "type='(Optional<UIWindow>.Type) -> (()) -> Optional<UIWindow>'", "decl=Swift.(file).Optional.init(nilLiteral:)", "[with UIWindow]", "function_ref=single"]

  end  

  def test_children_parsing
    source = """
    (brace_stmt\
        (return_stmt implicit))
    """
    ast = SwiftAST::Parser.new.parse(source)
    assert_equal ast.name, "brace_stmt"
    assert_equal ast.parameters, []
    assert !ast.children.empty?, "Parser should be able to parse subtrees"

    return_statement = ast.children.first
    assert_equal return_statement.name, "return_stmt"
    assert_equal return_statement.parameters, ["implicit"]

  end

  def test_multiple_children_parsing 
    source = %{
    (func_decl implicit 'anonname=0x7f85f59df460' interface type='(AppDelegate) -> (Builtin.RawPointer, inout Builtin.UnsafeValueBuffer) -> (Builtin.RawPointer, Builtin.RawPointer?)' access=internal materializeForSet_for=window\
    (parameter_list\
    (parameter "self" type='AppDelegate' interface type='AppDelegate'))\
    (parameter_list\
    (parameter "buffer" type='Builtin.RawPointer' interface type='Builtin.RawPointer')\
    (parameter "callbackStorage" type='inout Builtin.UnsafeValueBuffer' interface type='inout Builtin.UnsafeValueBuffer' mutable)))\
    }

    ast = SwiftAST::Parser.new.parse(source)
    assert_equal ast.name, "func_decl"
    assert_equal ast.children.count, 2

  end  

  def test_complex_file_parsing
    source = IO.read('./test/fixtures/swift-dump-ast/appdelegate.ast')
    ast = SwiftAST::Parser.new.parse(source)
    assert_equal ast.name, "source_file"
  end  

  def test_even_more_complex_file_parsing
    source = IO.read('./test/fixtures/swift-dump-ast/first-file.ast')
    ast = SwiftAST::Parser.new.parse(source)
    assert_equal ast.name, "source_file"
  end  
    

end
