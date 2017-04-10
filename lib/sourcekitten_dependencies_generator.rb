require 'json'
require 'objc_dependency_tree_generator_helper'
require 'rexml/document'

module SKDeclarationType
  SWIFT_EXTENSION = 'source.lang.swift.decl.extension'.freeze
  SWIFT_PROTOCOL = 'source.lang.swift.decl.protocol'.freeze
  SWIFT_STRUCT = 'source.lang.swift.decl.struct'.freeze
  SWIFT_CLASS = 'source.lang.swift.decl.class'.freeze
  OBJC_PROTOCOL = 'sourcekitten.source.lang.objc.decl.protocol'.freeze
  OBJC_STRUCT = 'sourcekitten.source.lang.objc.decl.struct'.freeze
  OBJC_CLASS = 'sourcekitten.source.lang.objc.decl.class'.freeze

  INSTANCE_VARIABLE = 'source.lang.swift.decl.var.instance'.freeze
  INSTANCE_METHOD = 'source.lang.swift.decl.function.method.instance'.freeze
end

module SKKey
  SUBSTRUCTURE = 'key.substructure'.freeze
  KIND = 'key.kind'.freeze
  INHERITED_TYPES = 'key.inheritedtypes'.freeze
  NAME = 'key.name'.freeze
  TYPE_NAME = 'key.typename'.freeze
  ANNOTATED_DECLARATION = 'key.annotated_decl'.freeze
end


class SourcekittenDependenciesGenerator

  # @return [DependencyTree]
  def generate_dependencies(source_kitten_json)

    tree = DependencyTree.new

    file = File.read(source_kitten_json)
    parsed_files = JSON.parse(file)

    parsed_files.each do |parsed_file|
      parsed_file.each do |_path, contents|
        substructures = contents[SKKey::SUBSTRUCTURE]
        next unless substructures
        substructures.each { |substructure| parse_structure(substructure, tree) }
      end
    end

    tree
  end

  # @param [Hash] item array of sourcekitten substructure of class, protocol, whatever
  # @param [DependencyTree] tree Dependency tree to where register item
  # @param [DependencyItemType] type type of items to register
  def register_item_in_tree(item, type, tree)
    item_name = item[SKKey::NAME]
    tree.register(item_name, type)

    inherited_types = item[SKKey::INHERITED_TYPES]
    return unless inherited_types
    inherited_types.map { |o| o[SKKey::NAME] }.each { |inherited_type| tree.add(item_name, inherited_type) }
  end

  def parse_structure(element, tree, parsing_context = [])
    # any other subsctucst?
    sub_structures = element[SKKey::SUBSTRUCTURE]

    kind = element[SKKey::KIND]
    item_name = element[SKKey::NAME]

    case kind
    when SKDeclarationType::SWIFT_EXTENSION
      register_item_in_tree(element, DependencyItemType::UNKNOWN, tree)
      if item_name
        context = parsing_context + [item_name]
        parsing_context.each { |el_name| tree.add(el_name, item_name)}
        sub_structures.each { |it| parse_structure(it, tree, context) } if sub_structures
      end

    when SKDeclarationType::SWIFT_PROTOCOL, SKDeclarationType::OBJC_PROTOCOL
      register_item_in_tree(element, DependencyItemType::PROTOCOL, tree)
      if item_name
        context = parsing_context + [item_name]
        parsing_context.each { |el_name| tree.add(el_name, item_name)}
        sub_structures.each { |it| parse_structure(it, tree, context) } if sub_structures
      end

    when SKDeclarationType::SWIFT_STRUCT, SKDeclarationType::OBJC_STRUCT
      register_item_in_tree(element, DependencyItemType::STRUCTURE, tree)
      if item_name
        context = parsing_context + [item_name]
        parsing_context.each { |el_name| tree.add(el_name, item_name)}
        sub_structures.each { |it| parse_structure(it, tree, context) } if sub_structures
      end

    when SKDeclarationType::SWIFT_CLASS, SKDeclarationType::OBJC_CLASS
      register_item_in_tree(element, DependencyItemType::CLASS, tree)
      if item_name
        context = parsing_context + [item_name]
        parsing_context.each { |el_name| tree.add(el_name, item_name)}
        sub_structures.each { |it| parse_structure(it, tree, context) } if sub_structures

        register_types_from_annotated_declaration(element, item_name, tree)
      end

    when SKDeclarationType::INSTANCE_VARIABLE, SKDeclarationType::INSTANCE_METHOD
      name = element[SKKey::TYPE_NAME]
      return if name.nil?

      type_names(name).each do |type_name|
        parsing_context.each { |el_name| tree.add(el_name, type_name) }
      end

    else
      # do nothing
    end
  end

  def register_types_from_annotated_declaration(element, item_name, tree)
    annotated_decl = element[SKKey::ANNOTATED_DECLARATION]
    return if annotated_decl.nil?
    doc = REXML::Document.new(annotated_decl)
    doc.each_element('//Declaration/Type') do |el|
      dependency_type = el.text.to_s
      tree.add(item_name, dependency_type)

      # get el type
      attribute_el = el.attribute('usr')
      next if attribute_el.nil?

      attribute = attribute_el.to_s
      if attribute.start_with? 's:P'
        tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(pl)'
        tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(cs)'
        tree.register(dependency_type, DependencyItemType::CLASS)
      elsif attribute.start_with? 's:C'
        tree.register(dependency_type, DependencyItemType::CLASS)
      end

    end
  end

  # Returns an array of strings, which represents
  # @param [String] type_name_string sourcekitten type name
  # @return [Array<String>] array of types, found in this type
  def type_names(type_name_string)
    type_name_string
      .split(/\W+/)
      .select { |t| !t.empty? }
      .select { |t| !is_primitive_swift_type?(t) }
  end

end
