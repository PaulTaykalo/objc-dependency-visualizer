#!/usr/bin/ruby

require 'optparse'

options = {}

#Defaults
options[:exclusion_prefixes] = "NS|UI|CA"


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

  IO.popen("find ~/Library/Caches/appCode20/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
   f.each do |line|  
    paths << line
   end
  }

  IO.popen("find ~/Library/Caches/appCode30/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
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
     				puts "            { \"source\" : \"#{source}\", \"dest\" : \"#{dest}\" },"
      			end
      		end
	  end
    end
}  

puts <<-THEEND
         ]
    }
  ;  
THEEND

