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
      children = scan_children
      return if children.empty?
      node = Node.new("ast", [], children)
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
        children << Node.new(scan_name?, scan_parameters, scan_children)
        @scanner.scan(/(\s|\\|\n|\r|\t)*\)/)
      end  
      children
    end  

    def scan_name? 
      el_name = @scanner.scan(/\w+/)
      el_name
    end  

    def scan_parameter?()
      #white spaces are skipped

      # scan everything until space or opening sequence like ( < ' ". 
      # Since we can end up with closing bracket - we alos check for )

      prefix = @scanner.scan(/[^\s()<'"\[]+/) 

      next_char = @scanner.peek(1)
      return nil unless next_char

      case next_char
      when " "   # next parameter
        result = prefix
      when "\n"   # next parameter
        result = prefix
      when ")"   # closing bracket == end of element
        result = prefix
      when "\""  # doube quoted string 
        result = @scanner.scan(/./) + @scanner.scan_until(/"/)
        result = result[1..-2] unless prefix             
        result = (prefix || "") + result
      when "'"  # single quoted string 
        result =  @scanner.scan(/./) + @scanner.scan_until(/'/)
        result = result[1..-2] unless prefix             
        result = (prefix || "") + result + (scan_parameter? || "")
      when "<"  # kinda generic
        result = (prefix || "") +@scanner.scan(/./) + @scanner.scan_until(/>/) + (scan_parameter? || "")
      when "("
        return nil unless prefix
        result = prefix + @scanner.scan_until(/\)/) + (scan_parameter? || "")
       when "["
        result = (prefix || "") + scan_range

      end  

      result

    end

    def scan_range
      return unless @scanner.peek(1) == "["
      result = @scanner.scan(/./)

      while true
        inside = @scanner.scan(/[^\]\[]+/)  #everything but [ or ]
        result += inside || ""
        next_char = @scanner.peek(1)

        return result + @scanner.scan(/./) if next_char == "]" # we found the end
        result += scan_range if next_char == "["
        raise "Unexpected character #{next_char} - [ or ] expected" if next_char != "[" && next_char != "]"
      end

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
