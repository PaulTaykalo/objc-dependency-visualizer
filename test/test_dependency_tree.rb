require 'test/unit'
require 'dependency_tree'

class DependencyTreeTest < Test::Unit::TestCase

  def test_initial_state
    tree = DependencyTree.new
    assert_equal(0,tree.links_count, 'should have no links at the start')
  end

  def test_link_add
    tree = DependencyTree.new
    tree.add('source', 'dest')
    assert_equal(1, tree.links_count, 'should have correctly calculate links count')
    assert_equal(true, tree.connected?('source', 'dest'),'should link items')
    assert_equal(false, tree.connected?('dest', 'source'),'should have unidirectional links')
  end
end