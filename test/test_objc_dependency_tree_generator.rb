require "test/unit"
require 'objc_dependency_tree_generator'

class ObCDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = ObjCDependencyTreeGenerator.new({})
    assert_equal generator.find_dependencies, {}
  end
end