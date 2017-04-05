require 'test/unit'
require 'tree_serializer'
require 'dependency_tree'


class LinksSerializerTest < Test::Unit::TestCase

  def test_serialization_not_empty
    serializer = TreeSerializer.new(DependencyTree.new)
    assert_not_nil(serializer.serialize('json'), 'Serializer should not return nils')
  end

end