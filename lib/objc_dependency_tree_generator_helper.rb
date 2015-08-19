def find_project_output_directory(derived_data_paths, project_prefix, project_suffix_pattern, target_name)

  return nil unless derived_data_paths

  paths = []

  # looking for derived data
  derived_data_paths.each do |derived_data_path|
    IO.popen("find #{derived_data_path} -depth 1 -name \"#{project_prefix}#{project_suffix_pattern}\" -type d  -exec find {} -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" -type d \\; ") { |f|
      f.each do |line|
        paths << line
      end
    }
  end

  $stderr.puts "There were #{paths.length} directories found"
  if paths.empty?
    $stderr.puts "Cannot find projects that starts with '#{project_prefix}'"
    exit 1
  end

  filtered_by_target_paths = paths

  if target_name
    filtered_by_target_paths = paths.find_all { |path| /#{target_name}[^\.]*\.build\/Objects-normal/.match path }
    $stderr.puts "After target filtration there is #{filtered_by_target_paths.length} directories left"
    if paths.empty?
      $stderr.puts "Cannot find projects that starts with '#{project_prefix}'' and has target name that starts with '#{target_name}'"
      exit 1
    end
  end

  paths_sorted_by_time = filtered_by_target_paths.sort_by { |f| File.ctime(f.chomp) }

  last_modified_dir = paths_sorted_by_time.last.chomp
  $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"

  last_modified_dir
end


def object_files_in_dir(object_files_dir)
  IO.popen("find \"#{object_files_dir}\" -name \"*.o\"") { |f|
    f.each { |line| yield line }
  }
end

def swift_deps_files_in_dir(object_files_dir)
  Dir.glob("#{object_files_dir}/*.swiftdeps") { |file| yield file }
end

def symbol_names_in_files_in_dir(object_files_dir)
  IO.popen("find \"#{object_files_dir}\" -name \"*.o\" -exec /usr/bin/nm -o {} \\;") { |f|
    f.each { |line| yield line }
  }
end

def dwarfdump_tag_pointers_in_file(filename)
  IO.popen("dwarfdump \"#{filename.strip}\" | grep -A1 TAG_pointer_type") { |fd|
    fd.each { |line| yield line }
  }
end


def is_primitive_swift_type?(dest)
  /^(BOOL|Int|Int32|Int64|Int16|Int8|UInt|UInt32|UInt64|UInt16|UInt8|String|Character|Bool|Float|Double|Dictionary|Array|Set|AnyObject|Void)$/.match(dest) != nil
end

def is_filtered_swift_type?(dest)
  /(ClusterType|ScalarType|LiteralType)$/.match(dest) != nil #or /^([a-z])/.match(dest) != nil
end

def is_valid_dest?(dest, exclusion_prefixes)
  dest != nil and /^(#{exclusion_prefixes})/.match(dest) == nil and /^\w/.match(dest) != nil and !is_primitive_swift_type?(dest) and !is_filtered_swift_type?(dest)
end
