module SwiftAST
  class Parser 
    def parse(string)
      @scanner = StringScanner.new(string)
      @scanner.scan( /\(/)
      name = @scanner.scan(/\w+/)
      @scanner.skip(/\s+/)

      parameters = scan_parameters

      node = Node.new(name, parameters)
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

    def scan_parameter?(unwrap_strings = true)
      prefix = @scanner.scan_until(/\w|<|"|'|@|_/)
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
      when isalpha(char)
        rest = @scanner.scan(/([\w\.@\d\/-])*/)
        param_name = (char + rest)

        next_char = @scanner.peek(1)
        if next_char == ":"
          line_and_column = @scanner.scan(/:\d+:\d+/)
          return param_name + line_and_column
        elsif next_char == "="
          param_value = scan_parameter?(false) || ""
          return param_name + "=" + param_value    
        elsif next_char == "("
          file_part = @scanner.scan(/\(file\)\./)
          rest_part = scan_parameter? || ""
          return param_name + file_part + rest_part
                          
        else  
          return param_name
        end  
      end 
      result

    end    

    def isalpha(str)
      !str.match(/[^A-Za-z@_]/)
    end

  end

  class Node

    def initialize(name, parameters = [])
      @name = name
      @parameters = parameters
    end    

    def name
      @name
    end

    def parameters
      @parameters
    end    
  end      

end
