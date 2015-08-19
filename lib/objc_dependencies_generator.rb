class ObjcDependenciesGenerator

  def generate_dependencies(object_files_dir, include_dwarf_info)

    #Searching all the .o files and showing its information through nm call
    symbol_names_in_files_in_dir(object_files_dir) do |line|
      # See of output here
      # https://gist.github.com/PaulTaykalo/8d2618ea9741ea772004

      # Capturing filename as a source and class name as the dest
      match = /[^\w]*([^\.\/]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(line)
      next unless match

      source, dest = match[1, 2]

      yield source, dest
    end

    return unless include_dwarf_info

    object_files_in_dir(object_files_dir) do |filename|

      source = /.*\/(.+)\.o/.match(filename)[1]
      yield source, nil

      # Full output example https://gist.github.com/PaulTaykalo/62cd5d545301c8355cb5
      # With grep output example https://gist.github.com/PaulTaykalo/9d5ecbce8a30a412cdbe
      dwarfdump_tag_pointers_in_file(filename) do |tag_pointer_line|

        # Finding the name in types
        # AT_type( {0x00000456} ( objc_object ) )
        tag_pointer_for_class = /.*?AT_type\(\s\{.*?\}.*\(\s((function|const)\s)?([A-Z][^\)]+?)\*?\s\).*/.match(tag_pointer_line)
        next unless tag_pointer_for_class

        dest = tag_pointer_for_class[3]

        yield source, dest
      end
    end
  end

  def symbol_names_in_files_in_dir(object_files_dir)
    IO.popen("find \"#{object_files_dir}\" -name \"*.o\" -exec /usr/bin/nm -o {} \\;") { |f|
      f.each { |line| yield line }
    }
  end

  def object_files_in_dir(object_files_dir)
    IO.popen("find \"#{object_files_dir}\" -name \"*.o\"") { |f|
      f.each { |line| yield line }
    }
  end

  def dwarfdump_tag_pointers_in_file(filename)
    IO.popen("dwarfdump \"#{filename.strip}\" | grep -A1 TAG_pointer_type") { |fd|
      fd.each { |line| yield line }
    }
  end


end