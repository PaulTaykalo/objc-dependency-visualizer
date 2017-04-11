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
  STATIC_VARIABLE = 'source.lang.swift.decl.var.static'.freeze
  INSTANCE_METHOD = 'source.lang.swift.decl.function.method.instance'.freeze
  CLASS_METHOD = 'source.lang.swift.decl.function.method.class'.freeze
  CALL = 'source.lang.swift.expr.call'.freeze
  ARGUMENT = 'source.lang.swift.expr.argument'.freeze
  DICTIONARY = 'source.lang.swift.expr.dictionary'.freeze
  ARRAY = 'source.lang.swift.expr.array'.freeze
end

module SKKey
  SUBSTRUCTURE = 'key.substructure'.freeze
  KIND = 'key.kind'.freeze
  INHERITED_TYPES = 'key.inheritedtypes'.freeze
  NAME = 'key.name'.freeze
  TYPE_NAME = 'key.typename'.freeze
  ANNOTATED_DECLARATION = 'key.annotated_decl'.freeze
  FULLY_ANNOTATED_DECLARATION = 'key.fully_annotated_decl'.freeze
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

    when SKDeclarationType::INSTANCE_VARIABLE, SKDeclarationType::INSTANCE_METHOD, SKDeclarationType::STATIC_VARIABLE, SKDeclarationType::CLASS_METHOD
      parsing_context.each do |el_name|
        register_types_from_annotated_declaration(element, el_name, tree)
      end
      sub_structures.each { |it| parse_structure(it, tree, parsing_context) } if sub_structures

    when SKDeclarationType::CALL
      if item_name
        object_names = potential_object_anmes(item_name)
        object_names.each { |on| parsing_context.each { |el_name| tree.add(el_name, on)} }
      end
      sub_structures.each { |it| parse_structure(it, tree, parsing_context) } if sub_structures

    when SKDeclarationType::ARGUMENT, SKDeclarationType::DICTIONARY, SKDeclarationType::ARRAY
      sub_structures.each { |it| parse_structure(it, tree, parsing_context) } if sub_structures

    else
      # do nothing
    end
  end

  def register_types_from_annotated_declaration(element, item_name, tree)
    annotated_decl = element[SKKey::ANNOTATED_DECLARATION]
    return if annotated_decl.nil?
    doc = REXML::Document.new(annotated_decl)

    has_typealiases = false
    doc.each_element('//Declaration/Type') do |el|
      dependency_type = el.text.to_s

      # get el type
      attribute_el = el.attribute('usr')
      next if attribute_el.nil?

      if is_typealias(element, dependency_type)
        has_typealiases = true
        next
      end

      attribute = attribute_el.to_s
      if attribute.start_with? 's:P'
        tree.add(item_name, dependency_type)
        tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(pl)'
        tree.add(item_name, dependency_type)
        tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(cs)'
        tree.add(item_name, dependency_type)
        tree.register(dependency_type, DependencyItemType::CLASS)
      elsif attribute.start_with? 's:C'
        tree.add(item_name, dependency_type)
        tree.register(dependency_type, DependencyItemType::CLASS)
      end
    end

    register_types_from_type_name(element, item_name, tree) if has_typealiases
  end

  def register_types_from_type_name(element, item_name, tree)
    type_name_string = element[SKKey::TYPE_NAME]
    return if type_name_string.nil?

    generics = generic_parameters(element)
    type_names(type_name_string)
      .select { |type_name| !generics.include?(type_name) }
      .each { |type_name| tree.add(item_name, type_name) }

  end

  # @return [Array<String>] array of generic names for element
  def generic_parameters(element)
    fully_annotated_decl = element[SKKey::FULLY_ANNOTATED_DECLARATION]
    return [] if fully_annotated_decl.nil?
    generics = []
    doc = REXML::Document.new(fully_annotated_decl)
    doc.each_element('//decl.generic_type_param.name') do |el|
      generics.push(el.text.to_s)
    end
    generics
  end

  def is_typealias(element, name)
    fully_annotated_decl = element[SKKey::FULLY_ANNOTATED_DECLARATION]
    return false if fully_annotated_decl.nil?
    doc = REXML::Document.new(fully_annotated_decl)
    doc.each_element('//ref.typealias') do |el|
      return true if el.text.to_s == name
    end

    false
  end

  # Returns an array of strings, which represents type names
  # @param [String] type_name_string sourcekitten type name
  # @return [Array<String>] array of types, found in this type
  def type_names(type_name_string)
    type_name_string
      .split(/\W+/)
      .select { |t| !t.empty? }
      .select { |t| !is_primitive_swift_type?(t) }
  end

  def potential_object_anmes(call_string)
    (call_string.scan(/^[A-Z_][A-Za-z0-9_]+/) + call_string.scan(/\s[A-Z_][A-Za-z0-9_]+/))
      .select { |t| !t.empty? }
      .select { |t| !is_primitive_swift_type?(t) }
  end

end
