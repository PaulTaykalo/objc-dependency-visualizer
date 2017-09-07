grammar SwiftAST;

options {
  language = Ruby;    // <- this option must be set to Ruby
  output   = AST;
}


file: form *;

form: list;

forms: form* ;

list: '(' string_literal literals')';


literal: value_literal
	   | colon_literal
       | assignment_literal
       ;

value_literal: string_literal
	         | quoted_literal
	         | attribute_literal
	         | path_literal
	         | declaration_literal
	         ;

literals: (list | literal) *;

string_literal: string;
declaration_literal:
	DECLARATION_LITERAL;
   
assignment_literal: ASSIGNMENT_PREFIX (options{greedy=true;}: value_literal)? ;
colon_literal: COLON_LITERAL;
attribute_literal: ATTRIBUTE_LITERAL;
path_literal: PATH_LITERAL;

quoted_literal: single_quoted_literal 
              | double_quoted_literal
              | bracers_quoted_literal 
              | range_literal 
              ;    

single_quoted_literal:
   SINGLE_QUOTED_LITERAL;

double_quoted_literal:
   DOUBLE_QUOTED_LITERAL;

bracers_quoted_literal:
  BRACERS_QUOTED_LITERAL;   

range_literal:
  RANGE_LITERAL;   

DECLARATION_LITERAL:
   STRING '.(file).' ( options {greedy=false;} : . )* '@' PATH_LITERAL ;

SINGLE_QUOTED_LITERAL : '\'' ( options {greedy=false;} : . )* '\'' ;
DOUBLE_QUOTED_LITERAL : '"' ( options {greedy=false;} : . )* '"' ;
BRACERS_QUOTED_LITERAL : '<' ( options {greedy=false;} : . )* '>' ;
RANGE_LITERAL : '[' ( options {greedy=false;} : . )* ']' ;
ASSIGNMENT_PREFIX: STRING '=' ;
COLON_LITERAL: STRING ':' ;
ATTRIBUTE_LITERAL: '@' STRING ;
PATH_LITERAL: '/' (STRING | PATH_PARAMETER)+ ':' NUMBER ':' NUMBER ;


string: 
   STRING;

WHITESPACE : ( '\t' | ' ' | '\r' | '\n'| '\u000C' | '\\' )+ { $channel = HIDDEN; } ;

NUMBER: ('0'..'9')+;

PATH_PARAMETER: '.';

STRING: ('a'..'z' | 'A'..'Z' | '_' | '0'..'9' ) ('a'..'z' | 'A'..'Z' | '_' | '0'..'9' | '/' | '@' | '-' | '<' | '>' )*;
