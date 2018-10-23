class SwiftDependenciesGenerator

  def generate_dependencies(object_files_dir, ignorePods)
    # This thing need to be commented :) It's removes too many connections
    # YAML.add_domain_type("", "private") { |type, val|
    #   'AnyObject'
    # }

    ignoredClasses = Set.new
    ignoredClasses = ignoredClasses(object_files_dir) if ignorePods

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
          next if ignoredClasses.include?(source)
          yield source, nil

          top_level_deps.each do |dest|
            next if ignoredClasses.include?(dest)
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

  #path of .swiftdeps files of each class in the project
  def swift_deps_files_in_dir(object_files_dirs)
    dirs = Array(object_files_dirs)
    dirs.each do |dir|
      Dir.glob("#{dir}/*.swiftdeps") { |file| yield file }
    end
  end

  #path of .swiftdeps files of each class in imported CocoaPods
  def pods_deps_files_in_dir(object_files_dirs)
    dirs = Array(object_files_dirs)
    pathComponents = String(object_files_dirs).split('/')
    #goes back outside of project folder
    pathComponents.shift()
    5.times do pathComponents.pop() end
    #goes to pods folder
    pathComponents << "Pods.build" << "Debug-iphonesimulator"
    podsPath = pathComponents.join("/")
    Dir.glob("/#{podsPath}/*/Objects-normal/x86_64/*.swiftdeps") { |file| yield file }
  end

  # Creates set of ignored classes from CocoaPods
  def ignoredClasses(object_files_dir)
    ignoredClasses = Set.new

    pods_deps_files_in_dir(object_files_dir) do |pods_text_file|
      begin
        dependencies = YAML.load_file(pods_text_file)
      rescue Exception => e
        $stderr.puts 'Cannot read file  ' + pods_text_file + ' : This is possibly because output file was changed:' + e.message
        next
      end
      class_name = dependencies['provides']
      class_name = dependencies['provides-top-level'] if class_name.nil?
      next if class_name.nil?
      class_name.each do |source|
        ignoredClasses.add(source)
      end
      # ignoredClasses.add(String(class_name))
    end
    return ignoredClasses
  end

end