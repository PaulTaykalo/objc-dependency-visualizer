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

    def generate_dependencies(source_kitten_json)

    	file = File.read(source_kitten_json)
    	parsed_files = JSON.parse(file)

        context = ParsingContext.new 

    	parsed_files.each { |file|  
    		file.each { |path, contents|
				substructures = contents[SK_KEY::Substructure]
				substructures.each { | substruct| parse_substructure(substruct, context) }
    		}
    	}

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

end
