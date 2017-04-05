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

module SKKey
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

  # @return [DependencyTree]
  def generate_dependencies(source_kitten_json)

    tree = DependencyTree.new

    file = File.read(source_kitten_json)
    parsed_files = JSON.parse(file)

    context = ParsingContext.new

    parsed_files.each do |parsed_file|
      parsed_file.each do |_path, contents|
        substructures = contents[SKKey::SUBSTRUCTURE]
        next unless substructures
        substructures.each { |substructure| parse_substructure(substructure, context) }
      end
    end

    context.classes.each do |clz|
      class_name = clz[SKKey::NAME]
      tree.register(class_name, DependencyItemType::CLASS)

      inherited_types = clz[SKKey::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SKKey::NAME] }.each { |type| tree.add(class_name, type) }
    end

    context.protocols.each do |clz|
      protocol_name = clz[SKKey::NAME]
      tree.register(protocol_name, DependencyItemType::PROTOCOL)

      inherited_types = clz[SKKey::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SKKey::NAME] }.each { |type| tree.add(protocol_name, type) }
    end

    context.extensions.each do |clz|
      extension_name = clz[SKKey::NAME]

      inherited_types = clz[SKKey::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SKKey::NAME] }.each { |type| tree.add(extension_name, type) }
    end

    context.structs.each do |clz|
      struct_name = clz[SKKey::NAME]
      tree.register(struct_name, DependencyItemType::STRUCTURE)

      inherited_types = clz[SKKey::INHERITED_TYPES]
      next unless inherited_types
      inherited_types.map { |o| o[SKKey::NAME] }.each { |type| tree.add(struct_name, type) }
    end

    tree
  end

  def parse_substructure(structure, context)
    # any other subsctucst?
    subsubstructures = structure[SKKey::SUBSTRUCTURE]
    subsubstructures.each { |it| parse_substructure(it, context) } if subsubstructures

    kind = structure[SKKey::KIND]

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
