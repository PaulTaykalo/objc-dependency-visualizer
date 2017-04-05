require 'json'

module SKDeclarationType
  SWIFT_EXTENSION = 'source.lang.swift.decl.extension'.freeze
  SWIFT_PROTOCOL = 'source.lang.swift.decl.protocol'.freeze
  SWIFT_STRUCT = 'source.lang.swift.decl.struct'.freeze
  SWIFT_CLASS = 'source.lang.swift.decl.class'.freeze
  OBJC_PROTOCOL = 'sourcekitten.source.lang.objc.decl.protocol'.freeze
  OBJC_STRUCT = 'sourcekitten.source.lang.objc.decl.struct'.freeze
  OBJC_CLASS = 'sourcekitten.source.lang.objc.decl.class'.freeze
end

module SK_KEY
  SUBSTRUCTURE = 'key.substructure'.freeze
  KIND = 'key.kind'.freeze
  INHERITED_TYPES = 'key.inheritedtypes'.freeze
  NAME = 'key.name'.freeze
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

    parsed_files.each do |parsed_file|
      parsed_file.each do |_path, contents|
        substructures = contents[SK_KEY::SUBSTRUCTURE]
        next unless substructures
        substructures.each { |substructure| parse_substructure(substructure, context) }
      end
    end

    context.classes.each do |clz|
      class_name = clz[SK_KEY::NAME]
      yield class_name, class_name

      inherited_types = clz[SK_KEY::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SK_KEY::NAME] }.each { |type| yield class_name, type }
    end

    context.protocols.each do |clz|
      protocol_name = clz[SK_KEY::NAME]
      yield protocol_name, protocol_name

      inherited_types = clz[SK_KEY::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SK_KEY::NAME] }.each { |type| yield protocol_name, type }
    end

    context.extensions.each do |clz|
      extension_name = clz[SK_KEY::NAME]

      inherited_types = clz[SK_KEY::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SK_KEY::NAME] }.each { |type| yield extension_name, type }
    end

    context.structs.each do |clz|
      struct_name = clz[SK_KEY::NAME]
      yield struct_name, struct_name

      inherited_types = clz[SK_KEY::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SK_KEY::NAME] }.each { |type| yield struct_name, type }
    end

  end

  def parse_substructure(structure, context)
    # any other subsctucst?
    subsubstructures = structure[SK_KEY::SUBSTRUCTURE]
    subsubstructures.each { |it| parse_substructure(it, context) } if subsubstructures

    kind = structure[SK_KEY::KIND]

    case kind
    when SKDeclarationType::SWIFT_EXTENSION
      context.extensions << structure
    when SKDeclarationType::SWIFT_PROTOCOL, SKDeclarationType::OBJC_PROTOCOL
      context.protocols << structure
    when SKDeclarationType::SWIFT_STRUCT, SKDeclarationType::OBJC_STRUCT
      context.structs << structure
    when SKDeclarationType::SWIFT_CLASS, SKDeclarationType::OBJC_CLASS
      context.classes << structure
    end
  end

end
