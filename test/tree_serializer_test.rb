require 'test/unit'
require 'tree_serializer'
require 'dependency_tree'
require 'json'


class TreeSerializerTest < Test::Unit::TestCase

  def test_serialization_not_empty
    serializer = TreeSerializer.new(DependencyTree.new)
    assert_not_nil(serializer.serialize('json'), 'Serializer should not return nils')
  end

  def test_link_serialization
    tree = DependencyTree.new
    tree.add('sourceItem', 'destItem')
    output = TreeSerializer.new(tree).serialize('json')
    json = JSON.parse(output)
    assert_not_nil(json['links'], 'Links should be present in output')

    first_link = json['links'].first
    assert_equal(first_link['source'], 'sourceItem', 'Links should have correct source set up')
    assert_equal(first_link['dest'], 'destItem', 'Links should have correct dest set up')
  end

  def test_types_serialization
    tree = DependencyTree.new
    tree.register('sourceItem', DependencyItemType::CLASS)
    output = TreeSerializer.new(tree).serialize('json')
    json = JSON.parse(output)
    assert_not_nil(json['objects'], 'Objects should be present in output')
    assert_not_nil(json['objects']['sourceItem'], 'Objects should be present in output')
    assert_equal(json['objects']['sourceItem']['type'], DependencyItemType::CLASS, 'Objects should be present in output')
  end

  def test_typed_link_serialization
    tree = DependencyTree.new
    tree.add('sourceItem', 'destItem', DependencyLinkType::INHERITANCE)
    output = TreeSerializer.new(tree).serialize('json')
    json = JSON.parse(output)
    assert_not_nil(json['links'], 'Links should be present in output')

    first_link = json['links'].first
    assert_equal(first_link['source'], 'sourceItem', 'Links should have correct source set up')
    assert_equal(first_link['dest'], 'destItem', 'Links should have correct dest set up')
    assert_equal(first_link['type'], DependencyLinkType::INHERITANCE, 'Links should have correct types')
  end


end