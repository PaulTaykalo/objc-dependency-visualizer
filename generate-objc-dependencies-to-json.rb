#!/usr/bin/ruby
if ARGV.first == nil 
	puts "generate-objc-dependencies-to-json.rb <directory> [exclude_prefixes]"
	puts " directory - is path to directory where your .o files were put by compiler"
	puts "   Example :"
	puts "     ~/Library/Developer/Xcode/DerivedData/MYPROJECT-esemwbhsllglridnecifwkfjbnlh/Build/Intermediates/MYPROJECT.build/Debug-iphoneos/MYPROJECT.build/Objects-normal/armv7"
	puts " "
	puts " exclude_prefixes - is a part of regex that will exclude some system frameworks from final visualization"
	puts "   Default value : NS|UI|CA "
	puts "   Example :  NS|UI"
	puts "              UI|CA|MF"
	exit 1
end


SEARCH_DIRECTORY = ARGV.first


EXCLUSION_PREFIXES = ARGV[1] != nil ? ARGV[1] : "NS|UI|CA"

#Header
puts <<-THEEND
   var dependencies = {
   	links:
   	  [
THEEND


#Searching all the .o files and showing its information through nm call
IO.popen("find \"#{SEARCH_DIRECTORY}\" -name \"*.o\" -exec nm -o {} \\;") { |f| 
	 f.each do |line|  


      # Gathering only OBC_CLASSES
      match = /_OBJC_CLASS_\$_/.match line

      if match != nil
            exclusion_match = /_OBJC_CLASS_\$_(#{EXCLUSION_PREFIXES})/.match line

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
