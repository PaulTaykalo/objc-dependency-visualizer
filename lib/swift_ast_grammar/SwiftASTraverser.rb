require_relative "SwiftASTLexer"
require_relative "SwiftASTParser"
# parser = SwiftAST::Parser.new( "(cool <parameter> )" )

input = ANTLR3::FileStream.new( 'swift.ast' )
parser = SwiftAST::Parser.new( input )
puts parser.form

# puts "#{SwiftAST::Parser.new( "<cool>" ).form}"
# puts "#{SwiftAST::Parser.new( "'cool'" ).form}"
# puts "#{SwiftAST::Parser.new( '"cool"' ).form}"
# puts "#{SwiftAST::Parser.new( 'cool' ).form}"

# puts "#{SwiftAST::Parser.new( '(name)' ).list}"
# puts "#{SwiftAST::Parser.new( '(name "cool")' ).list}"
# puts "#{SwiftAST::Parser.new( '(name <cool>)' ).list}"
# puts "#{SwiftAST::Parser.new( "(name '<cool>')" ).list}"
# puts "#{SwiftAST::Parser.new( "(name cool)" ).list}"

# puts "#{SwiftAST::Parser.new( "(name value='cool' anothervalue)" ).list}"

