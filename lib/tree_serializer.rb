class TreeSerializer
  attr_reader :dependency_tree

  def initialize(dependency_tree)
    @dependency_tree = dependency_tree
  end


  def serialize(output_format)
    object_to_serialize = {}
    object_to_serialize[:links] = @dependency_tree.links
    object_to_serialize[:links_count] = @dependency_tree.links_count

    case output_format
    when 'dot'
      serialize_to_dot(object_to_serialize)
    when 'json-pretty'
      serialize_to_json_pretty(object_to_serialize)
    when 'json'
      serialize_to_json(object_to_serialize)
    when 'json-var'
      serialize_to_json_var(object_to_serialize)
    when 'yaml'
      serialize_to_yaml(object_to_serialize)
    else
      raise
    end

  end

  def serialize_to_yaml(object_to_serialize)
    object_to_serialize.to_yaml
  end

  def serialize_to_json_var(object_to_serialize)
    'var dependencies = ' + object_to_serialize.to_json
  end

  def serialize_to_json(object_to_serialize)
    object_to_serialize.to_json
  end

  def serialize_to_json_pretty(object_to_serialize)
    JSON.pretty_generate(object_to_serialize)
  end

  def serialize_to_dot(object_to_serialize)
    indent = "\t"
    s = "digraph dependencies {\n#{indent}node [fontname=monospace, fontsize=9, shape=box, style=rounded]\n"
    object_to_serialize[:links].each do |link|
      s += "#{indent}\"#{link['source']}\" -> \"#{link['dest']}\"\n"
    end
    s += "}\n"
    s
  end

end