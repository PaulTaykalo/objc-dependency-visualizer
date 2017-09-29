module SwiftAST
  class Parser 
    def parse(string)
      @scanner = StringScanner.new(string)
      node = scan_children.first
      node
    end 

    
    def parse_build_log_output(string)
      @scanner = StringScanner.new(string)
      return unless @scanner.scan_until(/^\(source_file\\/)
      @scanner.pos = @scanner.pos - 13
      node = scan_children.first
      node
    end 


    def scan_parameters
      parameters = []

      while true
        @scanner.skip(/\s*/)
        parameter = scan_parameter?
        break unless parameter
        parameters << parameter
      end

      parameters
    end  

    def scan_children
      children = []
      while true
        return children unless @scanner.scan(/(\s|\\|\n|\r|\t)*\(/)
        children << Node.new(scan_parameter?, scan_parameters, scan_children)
        @scanner.scan(/(\s|\\|\n|\r|\t)*\)/)
      end  
      children
    end  

    def scan_parameter?(unwrap_strings = true)
      prefix = @scanner.scan(/(\s|\\)*(\w|\d|<|"|'|@|_|\/|\[|\*)/)
      return nil unless prefix

      char = prefix[-1]
      case 
      when char == "\""
        result = char + @scanner.scan_until(/"/)
        result = result[1..-2] if unwrap_strings
      when char == "'"
        result = char + @scanner.scan_until(/'/)
        result = result[1..-2] if unwrap_strings
        result += (@scanner.scan(/./) + scan_parameter?(false) || "") if isalphaOrDot(@scanner.peek(1))
      when char == "<"
        result = char + @scanner.scan_until(/>/)
      when char == "["
        result = char + scan_range
      when char == "*" 
        result = char + @scanner.scan_until(/\*NULL\*\*/) if @scanner.peek(7) == "*NULL**"
      when isAlphaDigit(char) || char == "/"
        rest = @scanner.scan(/([\w\.@\/,-])*/)
        param_name = (char + rest)
        result = param_name

        next_char = @scanner.peek(1)
        if next_char == ":"
          result += (scan_line_and_column || @scanner.scan(/:/))
        elsif next_char == "="
          result +=  @scanner.scan(/=/) + ( scan_parameter?(false) || "" )
        elsif next_char == "("
          rest = @scanner.scan_until(/\)/) 
          rest += ( @scanner.scan(/./) + scan_parameter?(false) || "" ) if isalphaOrDot(@scanner.peek(1))
          result += rest
        elsif next_char == "<"
          rest = @scanner.scan_until(/>/) 
          rest += ( @scanner.scan(/./) + scan_parameter?(false) || "" ) if isalphaOrDot(@scanner.peek(1))
          result += rest
        end  
      end 
      result
    end    

    def scan_range
      to_bracket = @scanner.scan_until(/\[|\]/)
      if to_bracket.end_with? "["
        to_bracket += scan_range #find closing of the opened
        to_bracket += scan_range #find closing of the original
      end
      return to_bracket
    end  

    def scan_line_and_column
      @scanner.scan(/:\d+:\d+/)
    end  

    def isalpha(str)
      !str.match(/[^A-Za-z@_]/)
    end
    def isAlphaDigit(str)
      !str.match(/[^A-Za-z@_0-9]/)
    end  
    def isalphaOrDot(str)
      !str.match(/[^A-Za-z@_.,]/)
    end

  end

  class Node

    def initialize(name, parameters = [], children = [])
      @name = name
      @parameters = parameters
      @children = children
    end    

    def name
      @name
    end

    def parameters
      @parameters
    end

    def children
      @children
    end    

    def dump(level = 0)
      puts "\n" if level == 0
      puts " " * level + "[#{@name} #{@parameters}"
      @children.each { |child| child.dump(level + 1) }
    end  

    def find_nodes(type)
      found_nodes = []
      @children.each { |child| 
        if child.name == type
           found_nodes << child
        else
           found_nodes += child.find_nodes(type)
        end      
      }
      found_nodes
    end  
  end      

end
