require 'set'

def find_project_output_directory(derived_data_paths, project_prefix, project_suffix_pattern, target_names, verbose)

  return nil unless derived_data_paths

  # all we need is log
  log = lambda { |message|
    $stderr.puts message if verbose
  }

  paths = []

  # looking for derived data
  derived_data_paths.each do |derived_data_path|
    IO.popen("find #{derived_data_path} -depth 1 -name \"#{project_prefix}#{project_suffix_pattern}\" -type d  -exec find {} -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" -type d \\; ") { |f|
      f.each do |line|
        paths << line
      end
    }
  end

  log.call "There were #{paths.length} directories found"
  if paths.empty?
    log.call "Cannot find projects that starts with '#{project_prefix}'"
    exit 1
  end

  filtered_by_target_paths = paths

  if target_names != nil && target_names.length > 0
    filtered_by_target_paths = paths.find_all { |path| 
       target_names.any? { |target| /#{target}[^\.]*\.build\/Objects-normal/.match path }
    }
    log.call "After target filtration there is #{filtered_by_target_paths.length} directories left"
    if paths.empty?
      log.call "Cannot find projects that starts with '#{project_prefix}'' and has target name that starts with '#{target_names}'"
      exit 1
    end

    paths_sorted_by_time = filtered_by_target_paths.sort_by { |f| File.ctime(f.chomp) }
    last_modified_dirs = target_names.map { |target|
      filtered_by_target = filtered_by_target_paths.find_all { |path| /#{target}[^\.]*\.build\/Objects-normal/.match path }
      last_modified_dir = filtered_by_target.last.chomp
      log.call "Last modifications for #{target} were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"
      last_modified_dir
    }
    return last_modified_dirs

  end

  paths_sorted_by_time = filtered_by_target_paths.sort_by { |f| File.ctime(f.chomp) }

  last_modified_dir = paths_sorted_by_time.last.chomp
  log.call "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"

  [last_modified_dir]
end
