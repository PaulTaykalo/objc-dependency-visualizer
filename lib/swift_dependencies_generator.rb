class SwiftDependenciesGenerator

  def generate_dependencies(object_files_dir)
    # This thing need to be commented :) It's removes too many connections
    # YAML.add_domain_type("", "private") { |type, val|
    #   'AnyObject'
    # }

    swift_deps_files_in_dir(object_files_dir) do |my_text_file|
      # puts my_text_file
      begin
        dependencies = YAML.load_file(my_text_file)
      rescue Exception => e
        $stderr.puts 'Cannot read file  ' + my_text_file + ' : This is possibly because output file was changed:' + e.message
        next
      end
      provided_objs = dependencies['provides']
      top_level_deps = dependencies['top-level']

      # support Xcode 7 format
      provided_objs = dependencies['provides-top-level'] if provided_objs.nil?
      top_level_deps = dependencies['depends-top-level'] if top_level_deps.nil?

      next if provided_objs.nil?
      next if top_level_deps.nil?

      if provided_objs.length == 1
        provided_objs.each do |source|
          yield source, nil
          top_level_deps.each do |dest|
            yield source, dest unless provided_objs.include?(dest)
          end
        end

      else

        filename = '< ' + File.basename(my_text_file, '.swiftdeps') +' >'
        provided_objs.each do |source|
          yield source, filename
        end

        yield filename, nil

        top_level_deps.each do |dest|
          yield filename, dest unless provided_objs.include?(dest)
        end
      end
    end
  end

  def swift_deps_files_in_dir(object_files_dirs)
    dirs = Array(object_files_dirs)
    dirs.each do |dir|
      Dir.glob("#{dir}/*.swiftdeps") { |file| yield file }
    end  
  end


end