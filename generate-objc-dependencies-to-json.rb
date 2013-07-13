#!/usr/bin/ruby
SEARCH_DIRECTORY = "."
EXCLUSION_PREFIXES = "NS|UI"

#Header
puts <<-THEEND
   var dependencies = {
   	links:
   	  [
THEEND


#Searching all the .o files and showing its information through nm call
IO.popen("find #{SEARCH_DIRECTORY} -name \"*.o\" -exec nm -o {} \\;") { |f| 
	 f.each do |line|  


      # Gathering only OBC_CLASSES
      match = /_OBJC_CLASS_\$_/.match line

      if match != nil
            exclusion_match = /_OBJC_CLASS_\$_(#{EXCLUSION_PREFIXES})/.match line

      		# Excluding base frameworks prefixes
      		if exclusion_match == nil

      			#Capturing filename (We'll think that this is source)
      			#And dependency (We'll think that this is the destination)

      			source,dest = /[^\w]*([^\.]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(line)[1,2]
                puts "            { \"source\" : \"#{source}\", \"dest\" : \"#{dest}\" },"
      		end
	  end
    end
}  

puts <<-THEEND
         ]
    }
  ;  
THEEND
