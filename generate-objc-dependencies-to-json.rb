#!/usr/bin/ruby

require 'optparse'

options = {}

#Defaults
options[:exclusion_prefixes] = "NS|UI|CA|CG|CI"


parser = OptionParser.new do |o|
  o.separator "General options:"

  o.on('-p PATH', "Path to directory where are your .o files were placed by the compiler") { |directory| 
    options[:search_directory] = directory
  }
  o.on('-s PROJECT_NAME', "Search project .o files by specified project name") { |project_name| 
    options[:project_name] = project_name
  }
  o.on('-t TARGET_NAME', "Target of project") { |target_name| 
    options[:target_name] = target_name
  }
  o.on('-e PREFIXES', "Prefixes of classes those will be exсluded from visualization. \n\t\t\t\t\tNS|UI\n\t\t\t\t\tUI|CA|MF") { |exclusion_prefixes| 
    options[:exclusion_prefixes] = exclusion_prefixes
  }

  o.on("-d", "--use-dwarf-info", "Use DWARF Information also") { |v|
    options[:use_dwarf] = v
  }

  o.separator "Common options:"
  o.on_tail('-h', "Prints this help") { puts o; exit }
  o.parse!
end

if options[:project_name]
  paths = []
  IO.popen("find ~/Library/Developer/Xcode/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
   f.each do |line|  
    paths << line
   end
  }

  IO.popen("find ~/Library/Caches/appCode*/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
   f.each do |line|  
    paths << line
   end
  }
  
  $stderr.puts "There were #{paths.length} directories found"
  if paths.empty?
    $stderr.puts "Cannot find projects that starts with '#{options[:project_name]}'"
    exit 1
  end  

  filtered_by_target_paths = paths

  if options[:target_name]
    filtered_by_target_paths = paths.find_all { |path| /#{options[:target_name]}[^\.]*\.build\/Objects-normal/.match path }
    $stderr.puts "After target filtration there is #{filtered_by_target_paths.length} directories left"
    if paths.empty?
      $stderr.puts "Cannot find projects that starts with '#{options[:project_name]}'' and has target name that starts with '#{options[:target_name]}'"
      exit 1
    end  

  end

  paths_sorted_by_time = filtered_by_target_paths.sort_by{ |f| 
    File.ctime(f.chomp)
  }

  last_modified_dir = paths_sorted_by_time.last.chomp
  $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}" 
  
  options[:search_directory] = last_modified_dir
end

if !options[:search_directory]
  puts parser.help
  exit 1
end


#Header
puts <<-THEEND
   var dependencies = {
   	links:
   	  [
THEEND

links = {}

#Searching all the .o files and showing its information through nm call
IO.popen("find \"#{options[:search_directory]}\" -name \"*.o\" -exec  /usr/bin/nm -o {} \\;") { |f| 
	 f.each do |line|  

      # Gathering only OBC_CLASSES
      match = /_OBJC_CLASS_\$_/.match line

      if match != nil
            exclusion_match = /_OBJC_CLASS_\$_(#{options[:exclusion_prefixes]})/.match line

      		# Excluding base frameworks prefixes
      		if exclusion_match == nil

      			#Capturing filename (We'll think that this is source)
      			#And dependency (We'll think that this is the destination)

      			source,dest = /[^\w]*([^\.\/]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(line)[1,2]
      			if source != dest 
              destinations = links[source] ? links[source] : (links[source] = {})
              destinations[dest] = "set up"
      			end
      		end
	    end
   end
}  

if options[:use_dwarf]

  # Search files again
  IO.popen("find \"#{options[:search_directory]}\" -name \"*.o\"") { |f| 
     f.each do |line|  

      # puts "Running dwarfdump #{line} | grep -A1 TAG_pointer_type"
      source = /.*\/(.+)\.o/.match(line)[1]
      IO.popen("dwarfdump #{line.strip} | grep -A1 TAG_pointer_type") { |fd| 
        fd.each do |line2|
          # Finding the name in types
          # AT_type( {0x00000456} ( objc_object ) )
          name = /.*?AT_type\(\s\{.*?\}.*\(\s((function|const)\s)?([A-Z][^\)]+?)\*?\s\).*/.match(line2)
          if name != nil
             dest = name[3] 
             if /^(#{options[:exclusion_prefixes]})/.match(dest) == nil
                if source != dest and dest != "BOOL"
                  destinations = links[source] ? links[source] : (links[source] = {})
                  destinations[dest] = "set up"
                end
             end 
          end
        end
      }
    end
  }
end

sources_count = links.length
links_count = 0
links.each do |source, dest_hash|
  links_count = links_count + dest_hash.length
  dest_hash.each do |dest, _ |
    puts "            { \"source\" : \"#{source}\", \"dest\" : \"#{dest}\" },"
  end  
end



puts <<-THEEND
         ],
     "source_files_count":#{sources_count},    
     "links_count":#{links_count},    
    }
  ;  
THEEND

