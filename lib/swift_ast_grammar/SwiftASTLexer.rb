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

  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = SwiftAST
    include TokenData

    begin
      generated_using( "SwiftAST.g", "3.5", "1.10.0" )
    rescue NoMethodError => error
      # ignore
    end

    RULE_NAMES   = [ "T__17", "T__18", "DECLARATION_LITERAL", "SINGLE_QUOTED_LITERAL", 
                     "DOUBLE_QUOTED_LITERAL", "BRACERS_QUOTED_LITERAL", 
                     "RANGE_LITERAL", "ASSIGNMENT_PREFIX", "COLON_LITERAL", 
                     "ATTRIBUTE_LITERAL", "PATH_LITERAL", "WHITESPACE", 
                     "NUMBER", "PATH_PARAMETER", "STRING" ].freeze
    RULE_METHODS = [ :t__17!, :t__18!, :declaration_literal!, :single_quoted_literal!, 
                     :double_quoted_literal!, :bracers_quoted_literal!, 
                     :range_literal!, :assignment_prefix!, :colon_literal!, 
                     :attribute_literal!, :path_literal!, :whitespace!, 
                     :number!, :path_parameter!, :string! ].freeze

    def initialize( input=nil, options = {} )
      super( input, options )
    end


    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule t__17! (T__17)
    # (in SwiftAST.g)
    def t__17!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )



      type = T__17
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 7:9: '('
      match( 0x28 )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 1 )


    end

    # lexer rule t__18! (T__18)
    # (in SwiftAST.g)
    def t__18!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )



      type = T__18
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 8:9: ')'
      match( 0x29 )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 2 )


    end

    # lexer rule declaration_literal! (DECLARATION_LITERAL)
    # (in SwiftAST.g)
    def declaration_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )



      type = DECLARATION_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 60:4: STRING '.(file).' ( options {greedy=false; } : . )* '@' PATH_LITERAL
      string!


      match( ".(file)." )

      # at line 60:22: ( options {greedy=false; } : . )*
      while true # decision 1
        alt_1 = 2
        look_1_0 = @input.peek( 1 )

        if ( look_1_0 == 0x40 )
          look_1_1 = @input.peek( 2 )

          if ( look_1_1 == 0x2f )
            look_1_3 = @input.peek( 3 )

            if ( look_1_3.between?( 0x30, 0x39 ) || look_1_3.between?( 0x41, 0x5a ) || look_1_3 == 0x5f || look_1_3.between?( 0x61, 0x7a ) )
              alt_1 = 2
            elsif ( look_1_3 == 0x2e )
              alt_1 = 2
            elsif ( look_1_3.between?( 0x0, 0x2d ) || look_1_3 == 0x2f || look_1_3.between?( 0x3a, 0x40 ) || look_1_3.between?( 0x5b, 0x5e ) || look_1_3 == 0x60 || look_1_3.between?( 0x7b, 0xffff ) )
              alt_1 = 1

            end
          elsif ( look_1_1.between?( 0x0, 0x2e ) || look_1_1.between?( 0x30, 0xffff ) )
            alt_1 = 1

          end
        elsif ( look_1_0.between?( 0x0, 0x3f ) || look_1_0.between?( 0x41, 0xffff ) )
          alt_1 = 1

        end
        case alt_1
        when 1
          # at line 60:50: .
          match_any

        else
          break # out of loop for decision 1
        end
      end # loop for decision 1

      match( 0x40 )

      path_literal!



      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 3 )


    end

    # lexer rule single_quoted_literal! (SINGLE_QUOTED_LITERAL)
    # (in SwiftAST.g)
    def single_quoted_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )



      type = SINGLE_QUOTED_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 62:25: '\\'' ( options {greedy=false; } : . )* '\\''
      match( 0x27 )
      # at line 62:30: ( options {greedy=false; } : . )*
      while true # decision 2
        alt_2 = 2
        look_2_0 = @input.peek( 1 )

        if ( look_2_0 == 0x27 )
          alt_2 = 2
        elsif ( look_2_0.between?( 0x0, 0x26 ) || look_2_0.between?( 0x28, 0xffff ) )
          alt_2 = 1

        end
        case alt_2
        when 1
          # at line 62:58: .
          match_any

        else
          break # out of loop for decision 2
        end
      end # loop for decision 2

      match( 0x27 )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )


    end

    # lexer rule double_quoted_literal! (DOUBLE_QUOTED_LITERAL)
    # (in SwiftAST.g)
    def double_quoted_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )



      type = DOUBLE_QUOTED_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 63:25: '\"' ( options {greedy=false; } : . )* '\"'
      match( 0x22 )
      # at line 63:29: ( options {greedy=false; } : . )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0 == 0x22 )
          alt_3 = 2
        elsif ( look_3_0.between?( 0x0, 0x21 ) || look_3_0.between?( 0x23, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 63:57: .
          match_any

        else
          break # out of loop for decision 3
        end
      end # loop for decision 3

      match( 0x22 )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )


    end

    # lexer rule bracers_quoted_literal! (BRACERS_QUOTED_LITERAL)
    # (in SwiftAST.g)
    def bracers_quoted_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )



      type = BRACERS_QUOTED_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 64:26: '<' ( options {greedy=false; } : . )* '>'
      match( 0x3c )
      # at line 64:30: ( options {greedy=false; } : . )*
      while true # decision 4
        alt_4 = 2
        look_4_0 = @input.peek( 1 )

        if ( look_4_0 == 0x3e )
          alt_4 = 2
        elsif ( look_4_0.between?( 0x0, 0x3d ) || look_4_0.between?( 0x3f, 0xffff ) )
          alt_4 = 1

        end
        case alt_4
        when 1
          # at line 64:58: .
          match_any

        else
          break # out of loop for decision 4
        end
      end # loop for decision 4

      match( 0x3e )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )


    end

    # lexer rule range_literal! (RANGE_LITERAL)
    # (in SwiftAST.g)
    def range_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )



      type = RANGE_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 65:17: '[' ( options {greedy=false; } : . )* ']'
      match( 0x5b )
      # at line 65:21: ( options {greedy=false; } : . )*
      while true # decision 5
        alt_5 = 2
        look_5_0 = @input.peek( 1 )

        if ( look_5_0 == 0x5d )
          alt_5 = 2
        elsif ( look_5_0.between?( 0x0, 0x5c ) || look_5_0.between?( 0x5e, 0xffff ) )
          alt_5 = 1

        end
        case alt_5
        when 1
          # at line 65:49: .
          match_any

        else
          break # out of loop for decision 5
        end
      end # loop for decision 5

      match( 0x5d )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )


    end

    # lexer rule assignment_prefix! (ASSIGNMENT_PREFIX)
    # (in SwiftAST.g)
    def assignment_prefix!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )



      type = ASSIGNMENT_PREFIX
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 66:20: STRING '='
      string!

      match( 0x3d )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )


    end

    # lexer rule colon_literal! (COLON_LITERAL)
    # (in SwiftAST.g)
    def colon_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )



      type = COLON_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 67:16: STRING ':'
      string!

      match( 0x3a )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )


    end

    # lexer rule attribute_literal! (ATTRIBUTE_LITERAL)
    # (in SwiftAST.g)
    def attribute_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )



      type = ATTRIBUTE_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 68:20: '@' STRING
      match( 0x40 )

      string!



      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 10 )


    end

    # lexer rule path_literal! (PATH_LITERAL)
    # (in SwiftAST.g)
    def path_literal!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )



      type = PATH_LITERAL
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 69:15: '/' ( STRING | PATH_PARAMETER )+ ':' NUMBER ':' NUMBER
      match( 0x2f )
      # at file 69:19: ( STRING | PATH_PARAMETER )+
      match_count_6 = 0
      while true
        alt_6 = 3
        look_6_0 = @input.peek( 1 )

        if ( look_6_0.between?( 0x30, 0x39 ) || look_6_0.between?( 0x41, 0x5a ) || look_6_0 == 0x5f || look_6_0.between?( 0x61, 0x7a ) )
          alt_6 = 1
        elsif ( look_6_0 == 0x2e )
          alt_6 = 2

        end
        case alt_6
        when 1
          # at line 69:20: STRING
          string!


        when 2
          # at line 69:29: PATH_PARAMETER
          path_parameter!


        else
          match_count_6 > 0 and break
          eee = EarlyExit(6)


          raise eee
        end
        match_count_6 += 1
      end


      match( 0x3a )

      number!

      match( 0x3a )

      number!



      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 11 )


    end

    # lexer rule whitespace! (WHITESPACE)
    # (in SwiftAST.g)
    def whitespace!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )



      type = WHITESPACE
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 75:14: ( '\\t' | ' ' | '\\r' | '\\n' | '\\u000C' | '\\\\' )+
      # at file 75:14: ( '\\t' | ' ' | '\\r' | '\\n' | '\\u000C' | '\\\\' )+
      match_count_7 = 0
      while true
        alt_7 = 2
        look_7_0 = @input.peek( 1 )

        if ( look_7_0.between?( 0x9, 0xa ) || look_7_0.between?( 0xc, 0xd ) || look_7_0 == 0x20 || look_7_0 == 0x5c )
          alt_7 = 1

        end
        case alt_7
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x9, 0xa ) || @input.peek( 1 ).between?( 0xc, 0xd ) || @input.peek(1) == 0x20 || @input.peek(1) == 0x5c
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse

          end



        else
          match_count_7 > 0 and break
          eee = EarlyExit(7)


          raise eee
        end
        match_count_7 += 1
      end



      # --> action
       channel = HIDDEN; 
      # <-- action



      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 12 )


    end

    # lexer rule number! (NUMBER)
    # (in SwiftAST.g)
    def number!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )



      type = NUMBER
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 77:9: ( '0' .. '9' )+
      # at file 77:9: ( '0' .. '9' )+
      match_count_8 = 0
      while true
        alt_8 = 2
        look_8_0 = @input.peek( 1 )

        if ( look_8_0.between?( 0x30, 0x39 ) )
          alt_8 = 1

        end
        case alt_8
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x30, 0x39 )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse

          end



        else
          match_count_8 > 0 and break
          eee = EarlyExit(8)


          raise eee
        end
        match_count_8 += 1
      end




      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 13 )


    end

    # lexer rule path_parameter! (PATH_PARAMETER)
    # (in SwiftAST.g)
    def path_parameter!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )



      type = PATH_PARAMETER
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 79:17: '.'
      match( 0x2e )


      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 14 )


    end

    # lexer rule string! (STRING)
    # (in SwiftAST.g)
    def string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )



      type = STRING
      channel = ANTLR3::DEFAULT_CHANNEL
    # - - - - label initialization - - - -


      # - - - - main rule block - - - -
      # at line 81:9: ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' | '/' | '@' | '-' | '<' | '>' )*
      if @input.peek( 1 ).between?( 0x30, 0x39 ) || @input.peek( 1 ).between?( 0x41, 0x5a ) || @input.peek(1) == 0x5f || @input.peek( 1 ).between?( 0x61, 0x7a )
        @input.consume
      else
        mse = MismatchedSet( nil )
        recover mse
        raise mse

      end


      # at line 81:49: ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' | '/' | '@' | '-' | '<' | '>' )*
      while true # decision 9
        alt_9 = 2
        look_9_0 = @input.peek( 1 )

        if ( look_9_0 == 0x2d || look_9_0.between?( 0x2f, 0x39 ) || look_9_0 == 0x3c || look_9_0 == 0x3e || look_9_0.between?( 0x40, 0x5a ) || look_9_0 == 0x5f || look_9_0.between?( 0x61, 0x7a ) )
          alt_9 = 1

        end
        case alt_9
        when 1
          # at line 
          if @input.peek(1) == 0x2d || @input.peek( 1 ).between?( 0x2f, 0x39 ) || @input.peek(1) == 0x3c || @input.peek(1) == 0x3e || @input.peek( 1 ).between?( 0x40, 0x5a ) || @input.peek(1) == 0x5f || @input.peek( 1 ).between?( 0x61, 0x7a )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse

          end



        else
          break # out of loop for decision 9
        end
      end # loop for decision 9



      @state.type = type
      @state.channel = channel
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 15 )


    end

    # main rule used to study the input at the current position,
    # and choose the proper lexer rule to call in order to
    # fetch the next token
    #
    # usually, you don't make direct calls to this method,
    # but instead use the next_token method, which will
    # build and emit the actual next token
    def token!
      # at line 1:8: ( T__17 | T__18 | DECLARATION_LITERAL | SINGLE_QUOTED_LITERAL | DOUBLE_QUOTED_LITERAL | BRACERS_QUOTED_LITERAL | RANGE_LITERAL | ASSIGNMENT_PREFIX | COLON_LITERAL | ATTRIBUTE_LITERAL | PATH_LITERAL | WHITESPACE | NUMBER | PATH_PARAMETER | STRING )
      alt_10 = 15
      alt_10 = @dfa10.predict( @input )
      case alt_10
      when 1
        # at line 1:10: T__17
        t__17!


      when 2
        # at line 1:16: T__18
        t__18!


      when 3
        # at line 1:22: DECLARATION_LITERAL
        declaration_literal!


      when 4
        # at line 1:42: SINGLE_QUOTED_LITERAL
        single_quoted_literal!


      when 5
        # at line 1:64: DOUBLE_QUOTED_LITERAL
        double_quoted_literal!


      when 6
        # at line 1:86: BRACERS_QUOTED_LITERAL
        bracers_quoted_literal!


      when 7
        # at line 1:109: RANGE_LITERAL
        range_literal!


      when 8
        # at line 1:123: ASSIGNMENT_PREFIX
        assignment_prefix!


      when 9
        # at line 1:141: COLON_LITERAL
        colon_literal!


      when 10
        # at line 1:155: ATTRIBUTE_LITERAL
        attribute_literal!


      when 11
        # at line 1:173: PATH_LITERAL
        path_literal!


      when 12
        # at line 1:186: WHITESPACE
        whitespace!


      when 13
        # at line 1:197: NUMBER
        number!


      when 14
        # at line 1:204: PATH_PARAMETER
        path_parameter!


      when 15
        # at line 1:219: STRING
        string!


      end
    end


    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA10 < ANTLR3::DFA
      EOT = unpack( 3, -1, 1, 14, 7, -1, 1, 19, 1, -1, 1, 14, 4, -1, 1, 
                    19, 1, -1 )
      EOF = unpack( 20, -1 )
      MIN = unpack( 1, 9, 2, -1, 1, 45, 7, -1, 1, 45, 1, -1, 1, 45, 4, -1, 
                    1, 45, 1, -1 )
      MAX = unpack( 1, 122, 2, -1, 1, 122, 7, -1, 1, 122, 1, -1, 1, 122, 
                    4, -1, 1, 122, 1, -1 )
      ACCEPT = unpack( 1, -1, 1, 1, 1, 2, 1, -1, 1, 4, 1, 5, 1, 6, 1, 7, 
                       1, 10, 1, 11, 1, 12, 1, -1, 1, 14, 1, -1, 1, 13, 
                       1, 3, 1, 8, 1, 9, 1, -1, 1, 15 )
      SPECIAL = unpack( 20, -1 )
      TRANSITION = [
        unpack( 2, 10, 1, -1, 2, 10, 18, -1, 1, 10, 1, -1, 1, 5, 4, -1, 
                1, 4, 1, 1, 1, 2, 4, -1, 1, 12, 1, 9, 10, 3, 2, -1, 1, 6, 
                3, -1, 1, 8, 26, 11, 1, 7, 1, 10, 2, -1, 1, 11, 1, -1, 26, 
                11 ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 18, 1, 15, 1, 18, 10, 13, 1, 17, 1, -1, 1, 18, 1, 16, 
                 1, 18, 1, -1, 27, 18, 4, -1, 1, 18, 1, -1, 26, 18 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 18, 1, 15, 11, 18, 1, 17, 1, -1, 1, 18, 1, 16, 1, 18, 
                 1, -1, 27, 18, 4, -1, 1, 18, 1, -1, 26, 18 ),
        unpack(  ),
        unpack( 1, 18, 1, 15, 1, 18, 10, 13, 1, 17, 1, -1, 1, 18, 1, 16, 
                 1, 18, 1, -1, 27, 18, 4, -1, 1, 18, 1, -1, 26, 18 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 18, 1, 15, 11, 18, 1, 17, 1, -1, 1, 18, 1, 16, 1, 18, 
                 1, -1, 27, 18, 4, -1, 1, 18, 1, -1, 26, 18 ),
        unpack(  )
      ].freeze

      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end

      @decision = 10


      def description
        <<-'__dfa_description__'.strip!
          1:1: Tokens : ( T__17 | T__18 | DECLARATION_LITERAL | SINGLE_QUOTED_LITERAL | DOUBLE_QUOTED_LITERAL | BRACERS_QUOTED_LITERAL | RANGE_LITERAL | ASSIGNMENT_PREFIX | COLON_LITERAL | ATTRIBUTE_LITERAL | PATH_LITERAL | WHITESPACE | NUMBER | PATH_PARAMETER | STRING );
        __dfa_description__
      end

    end


    private

    def initialize_dfas
      super rescue nil
      @dfa10 = DFA10.new( self, 10 )


    end

  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0

end
