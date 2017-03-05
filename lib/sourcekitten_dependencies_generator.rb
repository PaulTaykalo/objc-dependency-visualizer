require 'json'

module SK_DECLARATION_TYPE
	SwiftExtension = 'source.lang.swift.decl.extension'
	SwiftProtocol = 'source.lang.swift.decl.protocol'
	SwiftStruct = 'source.lang.swift.decl.struct'
	SwiftClass = 'source.lang.swift.decl.class'
	ObjCProtocol = 'sourcekitten.source.lang.objc.decl.protocol'
	ObjCStruct = 'sourcekitten.source.lang.objc.decl.struct'
	ObjCClass = 'sourcekitten.source.lang.objc.decl.class'
end	

module SK_KEY
    Substructure = 'key.substructure'
    Kind = "key.kind"
    InheritedTypes = 'key.inheritedtypes'
    Name = 'key.name'
end	

class ParsingContext
    attr_accessor :structs, :protocols, :classes, :extensions

    def initialize()
    	@structs = []
    	@protocols = []
    	@classes = []
    	@extensions = []
    end
end	

class SourceKittenDependenciesGenerator


    # SwiftExtension: 'source.lang.swift.decl.extension'
    # SwiftProtocol: 'source.lang.swift.decl.protocol'
    # SwiftStruct: 'source.lang.swift.decl.struct'
    # SwiftClass: 'source.lang.swift.decl.class'
    # ObjCProtocol: 'sourcekitten.source.lang.objc.decl.protocol'
    # ObjCStruct: 'sourcekitten.source.lang.objc.decl.struct'
    # ObjCClass: 'sourcekitten.source.lang.objc.decl.class'


    def generate_dependencies(source_kitten_json)

    	# $stderr.puts "!!!!!!!! #{source_kitten_json}"

    	file = File.read(source_kitten_json)
    	parsed_files = JSON.parse(file)

        context = ParsingContext.new 

    	parsed_files.each { |file|  
    		file.each { |path, contents|
				substructures = contents[SK_KEY::Substructure]
				substructures.each { | substruct| parse_substructure(substruct, context) }
    		}
    	}

    	# puts context.classes.map { |clz| "#{clz[SK_KEY::Name]}  #{clz[SK_KEY::InheritedTypes]}" }

    	context.classes.each { |clz|
    		classname = clz[SK_KEY::Name]
    		yield classname, classname

    		inheritedTypes = clz[SK_KEY::InheritedTypes]
    		if inheritedTypes 
    			inheritedTypes.map { |o| o[SK_KEY::Name] }.each { |type| 
    				yield classname, type
    			}
    		end	
    	}

    	context.protocols.each { |clz|
    		protocolname = clz[SK_KEY::Name]
    		yield protocolname, protocolname

    		inheritedTypes = clz[SK_KEY::InheritedTypes]
    		if inheritedTypes 
    			inheritedTypes.map { |o| o[SK_KEY::Name] }.each { |type| 
    				yield protocolname, type
    			}
    		end	
    	}

    	context.extensions.each { |clz|
    		extensionname = clz[SK_KEY::Name]

    		inheritedTypes = clz[SK_KEY::InheritedTypes]
    		if inheritedTypes 
    			inheritedTypes.map { |o| o[SK_KEY::Name] }.each { |type| 
    				yield extensionname, type
    			}
    		end	
    	}

    	context.structs.each { |clz|
    		structname = clz[SK_KEY::Name]
    		yield structname, structname

    		inheritedTypes = clz[SK_KEY::InheritedTypes]
    		if inheritedTypes 
    			inheritedTypes.map { |o| o[SK_KEY::Name] }.each { |type| 
    				yield structname, type
    			}
    		end	
    	}

    end

    def parse_substructure(structure, context)
    	# any other subsctucst?
    	subsubstructures = structure[SK_KEY::Substructure]
    	if subsubstructures 
    		subsubstructures.each { |it| parse_substructure(it, context) }    		
    	end

    	## get kind
    	kind = structure[SK_KEY::Kind]

    	case kind
     	when  SK_DECLARATION_TYPE::SwiftExtension
     		context.extensions << structure
		when  SK_DECLARATION_TYPE::SwiftProtocol,  SK_DECLARATION_TYPE::ObjCProtocol
     		context.protocols << structure
		when  SK_DECLARATION_TYPE::SwiftStruct, SK_DECLARATION_TYPE::ObjCStruct
     		context.structs << structure
		when  SK_DECLARATION_TYPE::SwiftClass, SK_DECLARATION_TYPE::ObjCClass
     		context.classes << structure
    	end
    end	

#     	case a
# when 1..5
#   "It's between 1 and 5"
# when 6
#   "It's 6"
# when String
#   "You passed a string"
# else
#   "You gave me #{a} -- I have no idea what to do with that."
# end


    # 	structure.each { |  |

    # 		if k == SK_KEY::Substructure 
    # 			# parse even more!
    # 			parse_substructure(v, context)
    # 		end

    #         if k == SK_KEY::Kind 
    #         	# Grab and have context be filled

    #         	if v == SK_DECLARATION_TYPE::SwiftExtension
    #         		context[:extensions] = (context[:extensions] || [])
    #         		puts "Exteiosn added " + 
    #         	end	

    #         end


    # 		# puts "key #{k} = value = #{v}"


    # 		# if v.key?[SK_KEY::Kind]
	   #  	# 	kind = v[SK_KEY::Kind]
    # 		# end	
    # 		# # puts "#{v[SK_KEY::Kind]}"
    # 		# # puts v.key
    # 	}
    # end	

end
