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

  def initialize(source_kitten_json)
    @source_kitten_json = source_kitten_json
  end
  # @return [DependencyTree]
  def generate_dependencies

    @tree = DependencyTree.new
    @context = []

    file = File.read(@source_kitten_json)
    parsed_files = JSON.parse(file)

    parsed_files.each do |parsed_file|
      parsed_file.each do |_path, contents|
        substructures = contents[SKKey::SUBSTRUCTURE] || next
        substructures.each { |substructure| parse_structure(substructure) }
      end
    end

    @tree
  end

  def in_context(name)
    @context.push(name)
    yield
    @context.pop
  end

  # @param [Hash] item array of sourcekitten substructure of class, protocol, whatever
  # @param [DependencyItemType] type type of items to register
  def register_item(item, type)
    item_name = item[SKKey::NAME]
    @tree.register(item_name, type)

    inherited_types = item[SKKey::INHERITED_TYPES] || return

    inherited_types.each do |inherited_type|
      inherited_type_name = inherited_type[SKKey::NAME]
      @tree.add(item_name, inherited_type_name)
    end

  end

  # @param [Hash] element SourceKitten source
  def parse_structure(element)

    kind = element[SKKey::KIND]
    item_name = element[SKKey::NAME]

    case kind
    when SKDeclarationType::SWIFT_EXTENSION
      process_element(element, DependencyItemType::UNKNOWN)

    when SKDeclarationType::SWIFT_PROTOCOL, SKDeclarationType::OBJC_PROTOCOL
      process_element(element, DependencyItemType::PROTOCOL)

    when SKDeclarationType::SWIFT_STRUCT, SKDeclarationType::OBJC_STRUCT
      process_element(element, DependencyItemType::STRUCTURE)

    when SKDeclarationType::SWIFT_CLASS, SKDeclarationType::OBJC_CLASS
      process_element(element, DependencyItemType::CLASS)
      register_types_from_annotated_declaration(element)

    when SKDeclarationType::INSTANCE_VARIABLE, SKDeclarationType::INSTANCE_METHOD, SKDeclarationType::STATIC_VARIABLE, SKDeclarationType::CLASS_METHOD
      @context.each do |el_name|
        register_types_from_annotated_declaration(element, el_name)
      end
      parse_substructures(element)

    when SKDeclarationType::CALL
      if item_name
        object_names = potential_object_names(item_name)
        object_names.each { |on| @context.each { |el_name| @tree.add(el_name, on, DependencyLinkType::CALL)} }
      end
      parse_substructures(element)

    when SKDeclarationType::ARGUMENT, SKDeclarationType::DICTIONARY, SKDeclarationType::ARRAY
      parse_substructures(element)

    else
      # do nothing
    end
  end

  # @param [Hash] item array of sourcekitten substructure of class, protocol, whatever
  # @param [DependencyItemType] type type of items to register
  def process_element(element, type)
    register_item(element, type)
    item_name = element[SKKey::NAME] || return
    link_items_from_context(item_name)
    in_context(item_name) do
      parse_substructures(element)
    end
  end

  def parse_substructures(element)
    sub_structures = element[SKKey::SUBSTRUCTURE] || return
    sub_structures.each { |it| parse_structure(it) }
  end

  def link_items_from_context(item_name)
    @context.each { |el_name| @tree.add(el_name, item_name) }
  end

  def register_types_from_annotated_declaration(element, name = nil)
    item_name = name || element[SKKey::NAME] || return
    annotated_decl = element[SKKey::ANNOTATED_DECLARATION] || return

    doc = REXML::Document.new(annotated_decl)

    has_typealiases = false
    doc.each_element('//Declaration/Type') do |el|
      dependency_type = el.text.to_s

      # get el type
      attribute_el = el.attribute('usr') || next

      if is_typealias(element, dependency_type)
        has_typealiases = true
        next
      end

      attribute = attribute_el.to_s
      if attribute.start_with? 's:P'
        @tree.add(item_name, dependency_type)
        @tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(pl)'
        @tree.add(item_name, dependency_type)
        @tree.register(dependency_type, DependencyItemType::PROTOCOL)
      elsif attribute.start_with? 'c:objc(cs)'
        @tree.add(item_name, dependency_type)
        @tree.register(dependency_type, DependencyItemType::CLASS)
      elsif attribute.start_with? 's:C'
        @tree.add(item_name, dependency_type)
        @tree.register(dependency_type, DependencyItemType::CLASS)
      end
    end

    register_types_from_type_name(element, item_name) if has_typealiases
  end

  def register_types_from_type_name(element, item_name)
    type_name_string = element[SKKey::TYPE_NAME] || return

    generics = generic_parameters(element)
    type_names(type_name_string)
      .select { |type_name| !generics.include?(type_name) }
      .each { |type_name| @tree.add(item_name, type_name) }

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

  def potential_object_names(call_string)
    (call_string.scan(/^[A-Z_][A-Za-z0-9_]+/) + call_string.scan(/\s[A-Z_][A-Za-z0-9_]+/))
      .select { |t| !t.empty? }
      .select { |t| !is_primitive_swift_type?(t) }
  end

end
