module SwiftAST
  class Parser 
    def parse(string)
      @scanner = StringScanner.new(string)
      node = scan_children.first
      node
    end 

    
    def parse_build_log_output(string)
      @scanner = StringScanner.new(string)
      return unless @scanner.scan_until(/^\(source_file/)

      @scanner.pos = @scanner.pos - 12
      children = scan_children

      return if children.empty?
      Node.new("ast", [], children)
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

    def scan_parameters_from_types
      first_param = @scanner.scan(/\d+:/)
      return [] unless first_param
      return [first_param] + scan_parameters
    end  

    def scan_children(level = 0)
      children = []
      while true
        return children unless whitespaces = whitespaces_at(level)
        node_name = scan_name?
        return children if node_name == "source_file" && level != 0 && unscan(node_name + whitespaces)
        node_parameters = scan_parameters

        node_children = scan_children(level + 1)

        while next_params = scan_parameters_from_types  # these are stupid params alike
          break if next_params.empty?
          node_parameters += next_params
          node_children += scan_children(level + 1)
        end  
        node = Node.new(node_name, node_parameters, node_children)

        children << node
        @scanner.scan(/(\s|\\|\n|\r|\t)*\)/)
      end  
      children
    end  

    def whitespaces_at(level = 0)
      whitespaces = @scanner.scan(/(\s|\\|\n|\r|\t)*\(/)
      if level == 0 && whitespaces.nil?
         whitespaces = @scanner.scan(/.*?\(source_file/m)
         return nil unless whitespaces
         unscan("source_file")
      end
      whitespaces 
    end  

    def unscan(string)
      @scanner.pos = @scanner.pos - string.length
    end  

    def scan_name? 
      el_name = @scanner.scan(/#?[\w:]+/)
      el_name
    end  

    def scan_parameter?(is_parsing_rvalue = false)
      #white spaces are skipped

      # scan everything until space or opening sequence like ( < ' ". 
      # Since we can end up with closing bracket - we alos check for )

      prefix = @scanner.scan(/[^\s()'"\[\\]+/) if is_parsing_rvalue
      prefix = @scanner.scan(/[^\s()<'"\[\\=]+/) unless is_parsing_rvalue

      next_char = @scanner.peek(1)
      return nil unless next_char
      should_unwrap_strings = !is_parsing_rvalue && !prefix

      case next_char
      when " "   # next parameter
        result = prefix
      when "\\"   # next parameter
        @scanner.scan(/./)
        result = prefix

      when "\n"   # next parameter
        result = prefix
      when ")"   # closing bracket == end of element
        result = prefix
      when "\""  # doube quoted string 
        result = @scanner.scan(/./) + @scanner.scan_until(/"/)
        result = result[1..-2] if should_unwrap_strings             
        result = (prefix || "") + result
      when "'"  # single quoted string 
        result =  @scanner.scan(/./) + @scanner.scan_until(/'/)
        result = result[1..-2] if should_unwrap_strings             
        result = (prefix || "") + result + (scan_parameter?(is_parsing_rvalue) || "")
      when "<"  # kinda generic
        result = (prefix || "") + @scanner.scan(/./)
        #in some cases this can be last char, just because we can end up with a=sdsd.function.< 
        result += @scanner.scan_until(/>/) + (scan_parameter?(is_parsing_rvalue) || "") 
      when "("
        return nil if !prefix && !is_parsing_rvalue
        result = (prefix || "") + @scanner.scan_until(/\)/) + (scan_parameter?(is_parsing_rvalue) || "")
       when "["
        result = (prefix || "") + scan_range + (scan_parameter?(is_parsing_rvalue) || "")
       when "=" 
        result = prefix + @scanner.scan(/./) + (scan_parameter?(true) || "")

      end  

      # puts "prefix is '#{prefix}'  ||#{is_parsing_rvalue} result =#{result}"

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
      @@line = 0 if level == 0
      puts "\n" if level == 0
      puts " " * level + "[#{@@line}][#{@name} #{@parameters}"
      @@line = @@line + 1
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

    def on_node(type, &block)
      @children.each { |child|
        yield child if child.name == type
        child.on_node(type, &block)
      }
    end

  end      

end
