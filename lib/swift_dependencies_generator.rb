class SwiftDependenciesGenerator

  def self.generate_dependencies(object_files_dir)
    # This thing need to be commented :) It's removes too many connections
    # YAML.add_domain_type("", "private") { |type, val|
    #   'AnyObject'
    # }

    swift_deps_files_in_dir(object_files_dir) do |my_text_file|
      # puts my_text_file
      dependencies = YAML.load_file(my_text_file)

      provided_objs = dependencies['provides']
      top_level_deps = dependencies['top-level']
      next unless provided_objs

      if provided_objs.length == 1
        provided_objs.each { |source|
          yield source, nil
          top_level_deps.each do |dest|
            yield source, dest unless provided_objs.include?(dest)
          end
        }
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


end