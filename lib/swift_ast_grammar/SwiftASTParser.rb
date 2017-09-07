#!/usr/bin/env ruby
#
# SwiftAST.g
# --
# Generated using ANTLR version: 3.5
# Ruby runtime library version: 1.10.0
# Input grammar file: SwiftAST.g
# Generated at: 2017-09-07 23:03:46
#

# ~~~> start load path setup
this_directory = File.expand_path( File.dirname( __FILE__ ) )
$LOAD_PATH.unshift( this_directory ) unless $LOAD_PATH.include?( this_directory )

antlr_load_failed = proc do
  load_path = $LOAD_PATH.map { |dir| '  - ' << dir }.join( $/ )
  raise LoadError, <<-END.strip!

Failed to load the ANTLR3 runtime library (version 1.10.0):

Ensure the library has been installed on your system and is available
on the load path. If rubygems is available on your system, this can
be done with the command:

  gem install antlr3

Current load path:
#{ load_path }

  END
end

defined?( ANTLR3 ) or begin

  # 1: try to load the ruby antlr3 runtime library from the system path
  require 'antlr3'

rescue LoadError

  # 2: try to load rubygems if it isn't already loaded
  defined?( Gem ) or begin
    require 'rubygems'
  rescue LoadError
    antlr_load_failed.call
  end

  # 3: try to activate the antlr3 gem
  begin
    defined?( gem ) and gem( 'antlr3', '~> 1.10.0' )
  rescue Gem::LoadError
    antlr_load_failed.call
  end

  require 'antlr3'

end
# <~~~ end load path setup

module SwiftAST
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :EOF => -1, :T__17 => 17, :T__18 => 18, :ASSIGNMENT_PREFIX => 4, 
                   :ATTRIBUTE_LITERAL => 5, :BRACERS_QUOTED_LITERAL => 6, 
                   :COLON_LITERAL => 7, :DECLARATION_LITERAL => 8, :DOUBLE_QUOTED_LITERAL => 9, 
                   :NUMBER => 10, :PATH_LITERAL => 11, :PATH_PARAMETER => 12, 
                   :RANGE_LITERAL => 13, :SINGLE_QUOTED_LITERAL => 14, :STRING => 15, 
                   :WHITESPACE => 16 )


    # register the proper human-readable name or literal value
    # for each token type
    #
    # this is necessary because anonymous tokens, which are
    # created from literal values in the grammar, do not
    # have descriptive names
    register_names( "ASSIGNMENT_PREFIX", "ATTRIBUTE_LITERAL", "BRACERS_QUOTED_LITERAL", 
                    "COLON_LITERAL", "DECLARATION_LITERAL", "DOUBLE_QUOTED_LITERAL", 
                    "NUMBER", "PATH_LITERAL", "PATH_PARAMETER", "RANGE_LITERAL", 
                    "SINGLE_QUOTED_LITERAL", "STRING", "WHITESPACE", "'('", 
                    "')'" )


  end


  class Parser < ANTLR3::Parser
    @grammar_home = SwiftAST
    include ANTLR3::ASTBuilder

    RULE_METHODS = [ :file, :form, :forms, :list, :literal, :value_literal, 
                     :literals, :string_literal, :declaration_literal, :assignment_literal, 
                     :colon_literal, :attribute_literal, :path_literal, 
                     :quoted_literal, :single_quoted_literal, :double_quoted_literal, 
                     :bracers_quoted_literal, :range_literal, :string ].freeze

    include TokenData

    begin
      generated_using( "SwiftAST.g", "3.5", "1.10.0" )
    rescue NoMethodError => error
      # ignore
    end

    def initialize( input, options = {} )
      super( input, options )
    end
    # - - - - - - - - - - - - Rules - - - - - - - - - - - - -
    FileReturnValue = define_return_scope

    #
    # parser rule file
    #
    # (in SwiftAST.g)
    # 9:1: file : ( form )* ;
    #
    def file
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )


      return_value = FileReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      form1 = nil



      begin
      root_0 = @adaptor.create_flat_list


      # at line 9:7: ( form )*
      # at line 9:7: ( form )*
      while true # decision 1
        alt_1 = 2
        look_1_0 = @input.peek( 1 )

        if ( look_1_0 == T__17 )
          alt_1 = 1

        end
        case alt_1
        when 1
          # at line 9:7: form
          @state.following.push( TOKENS_FOLLOWING_form_IN_file_39 )
          form1 = form
          @state.following.pop
          @adaptor.add_child( root_0, form1.tree )


        else
          break # out of loop for decision 1
        end
      end # loop for decision 1


      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 1 )


      end

      return return_value
    end

    FormReturnValue = define_return_scope

    #
    # parser rule form
    #
    # (in SwiftAST.g)
    # 11:1: form : list ;
    #
    def form
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )


      return_value = FormReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      list2 = nil



      begin
      root_0 = @adaptor.create_flat_list


      # at line 11:7: list
      @state.following.push( TOKENS_FOLLOWING_list_IN_form_48 )
      list2 = list
      @state.following.pop
      @adaptor.add_child( root_0, list2.tree )


      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 2 )


      end

      return return_value
    end

    FormsReturnValue = define_return_scope

    #
    # parser rule forms
    #
    # (in SwiftAST.g)
    # 13:1: forms : ( form )* ;
    #
    def forms
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )


      return_value = FormsReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      form3 = nil



      begin
      root_0 = @adaptor.create_flat_list


      # at line 13:8: ( form )*
      # at line 13:8: ( form )*
      while true # decision 2
        alt_2 = 2
        look_2_0 = @input.peek( 1 )

        if ( look_2_0 == T__17 )
          alt_2 = 1

        end
        case alt_2
        when 1
          # at line 13:8: form
          @state.following.push( TOKENS_FOLLOWING_form_IN_forms_55 )
          form3 = form
          @state.following.pop
          @adaptor.add_child( root_0, form3.tree )


        else
          break # out of loop for decision 2
        end
      end # loop for decision 2


      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 3 )


      end

      return return_value
    end

    ListReturnValue = define_return_scope

    #
    # parser rule list
    #
    # (in SwiftAST.g)
    # 15:1: list : '(' string_literal literals ')' ;
    #
    def list
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )


      return_value = ListReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      char_literal4 = nil
      char_literal7 = nil
      string_literal5 = nil
      literals6 = nil


      tree_for_char_literal4 = nil
      tree_for_char_literal7 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 15:7: '(' string_literal literals ')'
      char_literal4 = match( T__17, TOKENS_FOLLOWING_T__17_IN_list_64 )
      tree_for_char_literal4 = @adaptor.create_with_payload( char_literal4 )
      @adaptor.add_child( root_0, tree_for_char_literal4 )


      @state.following.push( TOKENS_FOLLOWING_string_literal_IN_list_66 )
      string_literal5 = string_literal
      @state.following.pop
      @adaptor.add_child( root_0, string_literal5.tree )

      @state.following.push( TOKENS_FOLLOWING_literals_IN_list_68 )
      literals6 = literals
      @state.following.pop
      @adaptor.add_child( root_0, literals6.tree )

      char_literal7 = match( T__18, TOKENS_FOLLOWING_T__18_IN_list_69 )
      tree_for_char_literal7 = @adaptor.create_with_payload( char_literal7 )
      @adaptor.add_child( root_0, tree_for_char_literal7 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 4 )


      end

      return return_value
    end

    LiteralReturnValue = define_return_scope

    #
    # parser rule literal
    #
    # (in SwiftAST.g)
    # 18:1: literal : ( value_literal | colon_literal | assignment_literal );
    #
    def literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )


      return_value = LiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      value_literal8 = nil
      colon_literal9 = nil
      assignment_literal10 = nil



      begin
      # at line 18:8: ( value_literal | colon_literal | assignment_literal )
      alt_3 = 3
      case look_3 = @input.peek( 1 )
      when ATTRIBUTE_LITERAL, BRACERS_QUOTED_LITERAL, DECLARATION_LITERAL, DOUBLE_QUOTED_LITERAL, PATH_LITERAL, RANGE_LITERAL, SINGLE_QUOTED_LITERAL, STRING then alt_3 = 1
      when COLON_LITERAL then alt_3 = 2
      when ASSIGNMENT_PREFIX then alt_3 = 3
      else
        raise NoViableAlternative( "", 3, 0 )

      end
      case alt_3
      when 1
        root_0 = @adaptor.create_flat_list


        # at line 18:10: value_literal
        @state.following.push( TOKENS_FOLLOWING_value_literal_IN_literal_77 )
        value_literal8 = value_literal
        @state.following.pop
        @adaptor.add_child( root_0, value_literal8.tree )


      when 2
        root_0 = @adaptor.create_flat_list


        # at line 19:7: colon_literal
        @state.following.push( TOKENS_FOLLOWING_colon_literal_IN_literal_85 )
        colon_literal9 = colon_literal
        @state.following.pop
        @adaptor.add_child( root_0, colon_literal9.tree )


      when 3
        root_0 = @adaptor.create_flat_list


        # at line 20:10: assignment_literal
        @state.following.push( TOKENS_FOLLOWING_assignment_literal_IN_literal_96 )
        assignment_literal10 = assignment_literal
        @state.following.pop
        @adaptor.add_child( root_0, assignment_literal10.tree )


      end
      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 5 )


      end

      return return_value
    end

    ValueLiteralReturnValue = define_return_scope

    #
    # parser rule value_literal
    #
    # (in SwiftAST.g)
    # 23:1: value_literal : ( string_literal | quoted_literal | attribute_literal | path_literal | declaration_literal );
    #
    def value_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )


      return_value = ValueLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      string_literal11 = nil
      quoted_literal12 = nil
      attribute_literal13 = nil
      path_literal14 = nil
      declaration_literal15 = nil



      begin
      # at line 23:14: ( string_literal | quoted_literal | attribute_literal | path_literal | declaration_literal )
      alt_4 = 5
      case look_4 = @input.peek( 1 )
      when STRING then alt_4 = 1
      when BRACERS_QUOTED_LITERAL, DOUBLE_QUOTED_LITERAL, RANGE_LITERAL, SINGLE_QUOTED_LITERAL then alt_4 = 2
      when ATTRIBUTE_LITERAL then alt_4 = 3
      when PATH_LITERAL then alt_4 = 4
      when DECLARATION_LITERAL then alt_4 = 5
      else
        raise NoViableAlternative( "", 4, 0 )

      end
      case alt_4
      when 1
        root_0 = @adaptor.create_flat_list


        # at line 23:16: string_literal
        @state.following.push( TOKENS_FOLLOWING_string_literal_IN_value_literal_111 )
        string_literal11 = string_literal
        @state.following.pop
        @adaptor.add_child( root_0, string_literal11.tree )


      when 2
        root_0 = @adaptor.create_flat_list


        # at line 24:13: quoted_literal
        @state.following.push( TOKENS_FOLLOWING_quoted_literal_IN_value_literal_125 )
        quoted_literal12 = quoted_literal
        @state.following.pop
        @adaptor.add_child( root_0, quoted_literal12.tree )


      when 3
        root_0 = @adaptor.create_flat_list


        # at line 25:13: attribute_literal
        @state.following.push( TOKENS_FOLLOWING_attribute_literal_IN_value_literal_139 )
        attribute_literal13 = attribute_literal
        @state.following.pop
        @adaptor.add_child( root_0, attribute_literal13.tree )


      when 4
        root_0 = @adaptor.create_flat_list


        # at line 26:13: path_literal
        @state.following.push( TOKENS_FOLLOWING_path_literal_IN_value_literal_153 )
        path_literal14 = path_literal
        @state.following.pop
        @adaptor.add_child( root_0, path_literal14.tree )


      when 5
        root_0 = @adaptor.create_flat_list


        # at line 27:13: declaration_literal
        @state.following.push( TOKENS_FOLLOWING_declaration_literal_IN_value_literal_167 )
        declaration_literal15 = declaration_literal
        @state.following.pop
        @adaptor.add_child( root_0, declaration_literal15.tree )


      end
      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 6 )


      end

      return return_value
    end

    LiteralsReturnValue = define_return_scope

    #
    # parser rule literals
    #
    # (in SwiftAST.g)
    # 30:1: literals : ( list | literal )* ;
    #
    def literals
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )


      return_value = LiteralsReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      list16 = nil
      literal17 = nil



      begin
      root_0 = @adaptor.create_flat_list


      # at line 30:11: ( list | literal )*
      # at line 30:11: ( list | literal )*
      while true # decision 5
        alt_5 = 3
        look_5_0 = @input.peek( 1 )

        if ( look_5_0 == T__17 )
          alt_5 = 1
        elsif ( look_5_0.between?( ASSIGNMENT_PREFIX, DOUBLE_QUOTED_LITERAL ) || look_5_0 == PATH_LITERAL || look_5_0.between?( RANGE_LITERAL, STRING ) )
          alt_5 = 2

        end
        case alt_5
        when 1
          # at line 30:12: list
          @state.following.push( TOKENS_FOLLOWING_list_IN_literals_186 )
          list16 = list
          @state.following.pop
          @adaptor.add_child( root_0, list16.tree )


        when 2
          # at line 30:19: literal
          @state.following.push( TOKENS_FOLLOWING_literal_IN_literals_190 )
          literal17 = literal
          @state.following.pop
          @adaptor.add_child( root_0, literal17.tree )


        else
          break # out of loop for decision 5
        end
      end # loop for decision 5


      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 7 )


      end

      return return_value
    end

    StringLiteralReturnValue = define_return_scope

    #
    # parser rule string_literal
    #
    # (in SwiftAST.g)
    # 32:1: string_literal : string ;
    #
    def string_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )


      return_value = StringLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      string18 = nil



      begin
      root_0 = @adaptor.create_flat_list


      # at line 32:17: string
      @state.following.push( TOKENS_FOLLOWING_string_IN_string_literal_200 )
      string18 = string
      @state.following.pop
      @adaptor.add_child( root_0, string18.tree )


      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 8 )


      end

      return return_value
    end

    DeclarationLiteralReturnValue = define_return_scope

    #
    # parser rule declaration_literal
    #
    # (in SwiftAST.g)
    # 33:1: declaration_literal : DECLARATION_LITERAL ;
    #
    def declaration_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )


      return_value = DeclarationLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __DECLARATION_LITERAL19__ = nil


      tree_for_DECLARATION_LITERAL19 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 34:2: DECLARATION_LITERAL
      __DECLARATION_LITERAL19__ = match( DECLARATION_LITERAL, TOKENS_FOLLOWING_DECLARATION_LITERAL_IN_declaration_literal_207 )
      tree_for_DECLARATION_LITERAL19 = @adaptor.create_with_payload( __DECLARATION_LITERAL19__ )
      @adaptor.add_child( root_0, tree_for_DECLARATION_LITERAL19 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 9 )


      end

      return return_value
    end

    AssignmentLiteralReturnValue = define_return_scope

    #
    # parser rule assignment_literal
    #
    # (in SwiftAST.g)
    # 36:1: assignment_literal : ASSIGNMENT_PREFIX ( options {greedy=true; } : value_literal )? ;
    #
    def assignment_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )


      return_value = AssignmentLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __ASSIGNMENT_PREFIX20__ = nil
      value_literal21 = nil


      tree_for_ASSIGNMENT_PREFIX20 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 36:21: ASSIGNMENT_PREFIX ( options {greedy=true; } : value_literal )?
      __ASSIGNMENT_PREFIX20__ = match( ASSIGNMENT_PREFIX, TOKENS_FOLLOWING_ASSIGNMENT_PREFIX_IN_assignment_literal_217 )
      tree_for_ASSIGNMENT_PREFIX20 = @adaptor.create_with_payload( __ASSIGNMENT_PREFIX20__ )
      @adaptor.add_child( root_0, tree_for_ASSIGNMENT_PREFIX20 )


      # at line 36:39: ( options {greedy=true; } : value_literal )?
      alt_6 = 2
      case look_6 = @input.peek( 1 )
      when STRING then alt_6 = 1
      when SINGLE_QUOTED_LITERAL then alt_6 = 1
      when DOUBLE_QUOTED_LITERAL then alt_6 = 1
      when BRACERS_QUOTED_LITERAL then alt_6 = 1
      when RANGE_LITERAL then alt_6 = 1
      when ATTRIBUTE_LITERAL then alt_6 = 1
      when PATH_LITERAL then alt_6 = 1
      when DECLARATION_LITERAL then alt_6 = 1
      end
      case alt_6
      when 1
        # at line 36:63: value_literal
        @state.following.push( TOKENS_FOLLOWING_value_literal_IN_assignment_literal_228 )
        value_literal21 = value_literal
        @state.following.pop
        @adaptor.add_child( root_0, value_literal21.tree )


      end

      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 10 )


      end

      return return_value
    end

    ColonLiteralReturnValue = define_return_scope

    #
    # parser rule colon_literal
    #
    # (in SwiftAST.g)
    # 37:1: colon_literal : COLON_LITERAL ;
    #
    def colon_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )


      return_value = ColonLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __COLON_LITERAL22__ = nil


      tree_for_COLON_LITERAL22 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 37:16: COLON_LITERAL
      __COLON_LITERAL22__ = match( COLON_LITERAL, TOKENS_FOLLOWING_COLON_LITERAL_IN_colon_literal_237 )
      tree_for_COLON_LITERAL22 = @adaptor.create_with_payload( __COLON_LITERAL22__ )
      @adaptor.add_child( root_0, tree_for_COLON_LITERAL22 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 11 )


      end

      return return_value
    end

    AttributeLiteralReturnValue = define_return_scope

    #
    # parser rule attribute_literal
    #
    # (in SwiftAST.g)
    # 38:1: attribute_literal : ATTRIBUTE_LITERAL ;
    #
    def attribute_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )


      return_value = AttributeLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __ATTRIBUTE_LITERAL23__ = nil


      tree_for_ATTRIBUTE_LITERAL23 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 38:20: ATTRIBUTE_LITERAL
      __ATTRIBUTE_LITERAL23__ = match( ATTRIBUTE_LITERAL, TOKENS_FOLLOWING_ATTRIBUTE_LITERAL_IN_attribute_literal_243 )
      tree_for_ATTRIBUTE_LITERAL23 = @adaptor.create_with_payload( __ATTRIBUTE_LITERAL23__ )
      @adaptor.add_child( root_0, tree_for_ATTRIBUTE_LITERAL23 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 12 )


      end

      return return_value
    end

    PathLiteralReturnValue = define_return_scope

    #
    # parser rule path_literal
    #
    # (in SwiftAST.g)
    # 39:1: path_literal : PATH_LITERAL ;
    #
    def path_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )


      return_value = PathLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __PATH_LITERAL24__ = nil


      tree_for_PATH_LITERAL24 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 39:15: PATH_LITERAL
      __PATH_LITERAL24__ = match( PATH_LITERAL, TOKENS_FOLLOWING_PATH_LITERAL_IN_path_literal_249 )
      tree_for_PATH_LITERAL24 = @adaptor.create_with_payload( __PATH_LITERAL24__ )
      @adaptor.add_child( root_0, tree_for_PATH_LITERAL24 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 13 )


      end

      return return_value
    end

    QuotedLiteralReturnValue = define_return_scope

    #
    # parser rule quoted_literal
    #
    # (in SwiftAST.g)
    # 41:1: quoted_literal : ( single_quoted_literal | double_quoted_literal | bracers_quoted_literal | range_literal );
    #
    def quoted_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )


      return_value = QuotedLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      single_quoted_literal25 = nil
      double_quoted_literal26 = nil
      bracers_quoted_literal27 = nil
      range_literal28 = nil



      begin
      # at line 41:15: ( single_quoted_literal | double_quoted_literal | bracers_quoted_literal | range_literal )
      alt_7 = 4
      case look_7 = @input.peek( 1 )
      when SINGLE_QUOTED_LITERAL then alt_7 = 1
      when DOUBLE_QUOTED_LITERAL then alt_7 = 2
      when BRACERS_QUOTED_LITERAL then alt_7 = 3
      when RANGE_LITERAL then alt_7 = 4
      else
        raise NoViableAlternative( "", 7, 0 )

      end
      case alt_7
      when 1
        root_0 = @adaptor.create_flat_list


        # at line 41:17: single_quoted_literal
        @state.following.push( TOKENS_FOLLOWING_single_quoted_literal_IN_quoted_literal_256 )
        single_quoted_literal25 = single_quoted_literal
        @state.following.pop
        @adaptor.add_child( root_0, single_quoted_literal25.tree )


      when 2
        root_0 = @adaptor.create_flat_list


        # at line 42:17: double_quoted_literal
        @state.following.push( TOKENS_FOLLOWING_double_quoted_literal_IN_quoted_literal_275 )
        double_quoted_literal26 = double_quoted_literal
        @state.following.pop
        @adaptor.add_child( root_0, double_quoted_literal26.tree )


      when 3
        root_0 = @adaptor.create_flat_list


        # at line 43:17: bracers_quoted_literal
        @state.following.push( TOKENS_FOLLOWING_bracers_quoted_literal_IN_quoted_literal_293 )
        bracers_quoted_literal27 = bracers_quoted_literal
        @state.following.pop
        @adaptor.add_child( root_0, bracers_quoted_literal27.tree )


      when 4
        root_0 = @adaptor.create_flat_list


        # at line 44:17: range_literal
        @state.following.push( TOKENS_FOLLOWING_range_literal_IN_quoted_literal_312 )
        range_literal28 = range_literal
        @state.following.pop
        @adaptor.add_child( root_0, range_literal28.tree )


      end
      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 14 )


      end

      return return_value
    end

    SingleQuotedLiteralReturnValue = define_return_scope

    #
    # parser rule single_quoted_literal
    #
    # (in SwiftAST.g)
    # 47:1: single_quoted_literal : SINGLE_QUOTED_LITERAL ;
    #
    def single_quoted_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )


      return_value = SingleQuotedLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __SINGLE_QUOTED_LITERAL29__ = nil


      tree_for_SINGLE_QUOTED_LITERAL29 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 48:4: SINGLE_QUOTED_LITERAL
      __SINGLE_QUOTED_LITERAL29__ = match( SINGLE_QUOTED_LITERAL, TOKENS_FOLLOWING_SINGLE_QUOTED_LITERAL_IN_single_quoted_literal_342 )
      tree_for_SINGLE_QUOTED_LITERAL29 = @adaptor.create_with_payload( __SINGLE_QUOTED_LITERAL29__ )
      @adaptor.add_child( root_0, tree_for_SINGLE_QUOTED_LITERAL29 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 15 )


      end

      return return_value
    end

    DoubleQuotedLiteralReturnValue = define_return_scope

    #
    # parser rule double_quoted_literal
    #
    # (in SwiftAST.g)
    # 50:1: double_quoted_literal : DOUBLE_QUOTED_LITERAL ;
    #
    def double_quoted_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )


      return_value = DoubleQuotedLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __DOUBLE_QUOTED_LITERAL30__ = nil


      tree_for_DOUBLE_QUOTED_LITERAL30 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 51:4: DOUBLE_QUOTED_LITERAL
      __DOUBLE_QUOTED_LITERAL30__ = match( DOUBLE_QUOTED_LITERAL, TOKENS_FOLLOWING_DOUBLE_QUOTED_LITERAL_IN_double_quoted_literal_352 )
      tree_for_DOUBLE_QUOTED_LITERAL30 = @adaptor.create_with_payload( __DOUBLE_QUOTED_LITERAL30__ )
      @adaptor.add_child( root_0, tree_for_DOUBLE_QUOTED_LITERAL30 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 16 )


      end

      return return_value
    end

    BracersQuotedLiteralReturnValue = define_return_scope

    #
    # parser rule bracers_quoted_literal
    #
    # (in SwiftAST.g)
    # 53:1: bracers_quoted_literal : BRACERS_QUOTED_LITERAL ;
    #
    def bracers_quoted_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 17 )


      return_value = BracersQuotedLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __BRACERS_QUOTED_LITERAL31__ = nil


      tree_for_BRACERS_QUOTED_LITERAL31 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 54:3: BRACERS_QUOTED_LITERAL
      __BRACERS_QUOTED_LITERAL31__ = match( BRACERS_QUOTED_LITERAL, TOKENS_FOLLOWING_BRACERS_QUOTED_LITERAL_IN_bracers_quoted_literal_361 )
      tree_for_BRACERS_QUOTED_LITERAL31 = @adaptor.create_with_payload( __BRACERS_QUOTED_LITERAL31__ )
      @adaptor.add_child( root_0, tree_for_BRACERS_QUOTED_LITERAL31 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 17 )


      end

      return return_value
    end

    RangeLiteralReturnValue = define_return_scope

    #
    # parser rule range_literal
    #
    # (in SwiftAST.g)
    # 56:1: range_literal : RANGE_LITERAL ;
    #
    def range_literal
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 18 )


      return_value = RangeLiteralReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __RANGE_LITERAL32__ = nil


      tree_for_RANGE_LITERAL32 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 57:3: RANGE_LITERAL
      __RANGE_LITERAL32__ = match( RANGE_LITERAL, TOKENS_FOLLOWING_RANGE_LITERAL_IN_range_literal_373 )
      tree_for_RANGE_LITERAL32 = @adaptor.create_with_payload( __RANGE_LITERAL32__ )
      @adaptor.add_child( root_0, tree_for_RANGE_LITERAL32 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 18 )


      end

      return return_value
    end

    StringReturnValue = define_return_scope

    #
    # parser rule string
    #
    # (in SwiftAST.g)
    # 72:1: string : STRING ;
    #
    def string
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 19 )


      return_value = StringReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look


      root_0 = nil

      __STRING33__ = nil


      tree_for_STRING33 = nil

      begin
      root_0 = @adaptor.create_flat_list


      # at line 73:4: STRING
      __STRING33__ = match( STRING, TOKENS_FOLLOWING_STRING_IN_string_577 )
      tree_for_STRING33 = @adaptor.create_with_payload( __STRING33__ )
      @adaptor.add_child( root_0, tree_for_STRING33 )



      # - - - - - - - rule clean up - - - - - - - -
      return_value.stop = @input.look( -1 )


      return_value.tree = @adaptor.rule_post_processing( root_0 )
      @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )


      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )


      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 19 )


      end

      return return_value
    end



    TOKENS_FOLLOWING_form_IN_file_39 = Set[ 1, 17 ]
    TOKENS_FOLLOWING_list_IN_form_48 = Set[ 1 ]
    TOKENS_FOLLOWING_form_IN_forms_55 = Set[ 1, 17 ]
    TOKENS_FOLLOWING_T__17_IN_list_64 = Set[ 15 ]
    TOKENS_FOLLOWING_string_literal_IN_list_66 = Set[ 4, 5, 6, 7, 8, 9, 11, 13, 14, 15, 17, 18 ]
    TOKENS_FOLLOWING_literals_IN_list_68 = Set[ 18 ]
    TOKENS_FOLLOWING_T__18_IN_list_69 = Set[ 1 ]
    TOKENS_FOLLOWING_value_literal_IN_literal_77 = Set[ 1 ]
    TOKENS_FOLLOWING_colon_literal_IN_literal_85 = Set[ 1 ]
    TOKENS_FOLLOWING_assignment_literal_IN_literal_96 = Set[ 1 ]
    TOKENS_FOLLOWING_string_literal_IN_value_literal_111 = Set[ 1 ]
    TOKENS_FOLLOWING_quoted_literal_IN_value_literal_125 = Set[ 1 ]
    TOKENS_FOLLOWING_attribute_literal_IN_value_literal_139 = Set[ 1 ]
    TOKENS_FOLLOWING_path_literal_IN_value_literal_153 = Set[ 1 ]
    TOKENS_FOLLOWING_declaration_literal_IN_value_literal_167 = Set[ 1 ]
    TOKENS_FOLLOWING_list_IN_literals_186 = Set[ 1, 4, 5, 6, 7, 8, 9, 11, 13, 14, 15, 17 ]
    TOKENS_FOLLOWING_literal_IN_literals_190 = Set[ 1, 4, 5, 6, 7, 8, 9, 11, 13, 14, 15, 17 ]
    TOKENS_FOLLOWING_string_IN_string_literal_200 = Set[ 1 ]
    TOKENS_FOLLOWING_DECLARATION_LITERAL_IN_declaration_literal_207 = Set[ 1 ]
    TOKENS_FOLLOWING_ASSIGNMENT_PREFIX_IN_assignment_literal_217 = Set[ 1, 5, 6, 8, 9, 11, 13, 14, 15 ]
    TOKENS_FOLLOWING_value_literal_IN_assignment_literal_228 = Set[ 1 ]
    TOKENS_FOLLOWING_COLON_LITERAL_IN_colon_literal_237 = Set[ 1 ]
    TOKENS_FOLLOWING_ATTRIBUTE_LITERAL_IN_attribute_literal_243 = Set[ 1 ]
    TOKENS_FOLLOWING_PATH_LITERAL_IN_path_literal_249 = Set[ 1 ]
    TOKENS_FOLLOWING_single_quoted_literal_IN_quoted_literal_256 = Set[ 1 ]
    TOKENS_FOLLOWING_double_quoted_literal_IN_quoted_literal_275 = Set[ 1 ]
    TOKENS_FOLLOWING_bracers_quoted_literal_IN_quoted_literal_293 = Set[ 1 ]
    TOKENS_FOLLOWING_range_literal_IN_quoted_literal_312 = Set[ 1 ]
    TOKENS_FOLLOWING_SINGLE_QUOTED_LITERAL_IN_single_quoted_literal_342 = Set[ 1 ]
    TOKENS_FOLLOWING_DOUBLE_QUOTED_LITERAL_IN_double_quoted_literal_352 = Set[ 1 ]
    TOKENS_FOLLOWING_BRACERS_QUOTED_LITERAL_IN_bracers_quoted_literal_361 = Set[ 1 ]
    TOKENS_FOLLOWING_RANGE_LITERAL_IN_range_literal_373 = Set[ 1 ]
    TOKENS_FOLLOWING_STRING_IN_string_577 = Set[ 1 ]

  end # class Parser < ANTLR3::Parser

  at_exit { Parser.main( ARGV ) } if __FILE__ == $0

end
