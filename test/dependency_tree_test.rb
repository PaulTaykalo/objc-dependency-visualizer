require 'minitest/autorun'
require 'dependency_tree'

class DependencyTreeTest < Minitest::Test

  def test_initial_state
    tree = DependencyTree.new
    assert_equal(0, tree.links_count, 'should have no links at the start')
    assert(tree.isEmpty?, 'should be empty at the start')
  end

  def test_link_add
    tree = DependencyTree.new
    tree.add('source', 'dest')
    assert_equal(1, tree.links_count, 'should have correctly calculate links count')
    assert_equal(true, tree.connected?('source', 'dest'), 'should link items')
    assert_equal(false, tree.connected?('dest', 'source'), 'should have unidirectional links')
  end

  def test_is_registered
    tree = DependencyTree.new
    assert(!tree.isRegistered?('source'))

    tree.add('source', 'dest')
    assert(tree.isRegistered?('source'))
    assert(tree.isRegistered?('dest'))
  end

  def test_registration
    tree = DependencyTree.new
    assert(!tree.isRegistered?('source'))

    tree.register('source')
    assert(tree.isRegistered?('source'))
  end

  def test_registration_with_type
    tree = DependencyTree.new
    tree.register('source', DependencyItemType::CLASS)
    assert(tree.isRegistered?('source'))
    assert_equal(tree.type('source'), DependencyItemType::CLASS)
  end

  def test_registration_without_type
    tree = DependencyTree.new
    tree.register('source')
    assert_equal(tree.type('source'), DependencyItemType::UNKNOWN)
  end

  def test_adding_links_doesnt_affect_registration
    tree = DependencyTree.new
    tree.register('source', DependencyItemType::CLASS)
    tree.add('source', 'dest')
    assert_equal(tree.type('source'), DependencyItemType::CLASS)
  end

  def test_specific_item_type_should_override_unknown
    tree = DependencyTree.new
    tree.register('source')
    tree.register('source', DependencyItemType::CLASS)
    assert_equal(tree.type('source'), DependencyItemType::CLASS)
  end

  def test_unknown_shouldnt_override_specific_item_type
    tree = DependencyTree.new
    tree.register('source', DependencyItemType::CLASS)
    tree.register('source', DependencyItemType::UNKNOWN)
    assert_equal(tree.type('source'), DependencyItemType::CLASS)
  end


  def test_identical_links
    tree = DependencyTree.new
    tree.add('source', 'dest')
    tree.add('source', 'dest')
    assert_equal(tree.links_count, 1)
  end

  def test_typed_link
    tree = DependencyTree.new
    tree.add('source', 'dest', DependencyLinkType::INHERITANCE)
    assert_equal(tree.link_type('source', 'dest'), DependencyLinkType::INHERITANCE)
  end

  def test_typed_link_explicit_type_overrides_unknown
    tree = DependencyTree.new
    tree.add('source', 'dest', DependencyLinkType::UNKNOWN)
    tree.add('source', 'dest', DependencyLinkType::INHERITANCE)
    assert_equal(tree.link_type('source', 'dest'), DependencyLinkType::INHERITANCE)
  end

  def test_typed_link_unknown_type_doesnt_override_explicit
    tree = DependencyTree.new
    tree.add('source', 'dest', DependencyLinkType::CALL)
    tree.add('source', 'dest', DependencyLinkType::UNKNOWN)
    assert_equal(tree.link_type('source', 'dest'), DependencyLinkType::CALL)
  end

end