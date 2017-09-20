module SwiftAST
  class Parser 
    def parse(string)

      @scanner = StringScanner.new(string)
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
        return children unless @scanner.scan_until(/\(/)
        children << Node.new(scan_parameter?, scan_parameters, scan_children)
        @scanner.scan(/(\s|\\)*\)/)
      end  
      children
    end  

    def scan_parameter?(unwrap_strings = true)
      prefix = @scanner.scan(/(\s|\\)*(\w|<|"|'|@|_|\/|\[)/)
      return nil unless prefix

      char = prefix[-1]

      case 
      when char == "\""
        result = char + @scanner.scan_until(/"/)
        result = result[1..-2] if unwrap_strings
      when char == "'"
        result = char + @scanner.scan_until(/'/)
        result = result[1..-2] if unwrap_strings
      when char == "<"
        result = char + @scanner.scan_until(/>/)
      when char == "["
        result = char + @scanner.scan_until(/\]/)
      when isalpha(char) || char == "/"
        rest = @scanner.scan(/([\w\.@\/-])*/)
        param_name = (char + rest)
        result = param_name

        next_char = @scanner.peek(1)
        if next_char == ":"
          result += (scan_line_and_column || ":")
        elsif next_char == "="
          result +=  @scanner.scan(/=/) + ( scan_parameter?(false) || "" )
        elsif next_char == "("
          is_file = @scanner.peek(7) == "(file)."
          result += @scanner.scan(/\(file\)\./) + ( scan_parameter?(false) || "" ) if is_file 
        end  
      end 
      result
    end    

    def scan_line_and_column
      @scanner.scan(/:\d+:\d+/)
    end  

    def isalpha(str)
      !str.match(/[^A-Za-z@_]/)
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
  end      

end
