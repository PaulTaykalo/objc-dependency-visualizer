require 'test/unit'
require 'objc_dependency_tree_generator'

class ObCDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = ObjCDependencyTreeGenerator.new({})
    assert_equal generator.find_dependencies, {}
  end

  def test_swift_simple_inheritance
    generator = ObjCDependencyTreeGenerator.new({
                                                    :search_directory => './test/fixtures/swift-simple-inheritance/x86_64',
                                                    :swift_dependencies => true
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['TwoClass'])
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['MasterViewController']['DetailViewController'])
    assert_not_nil(dependencies['AppDelegate']['TwoClass'])
    assert_not_nil(dependencies['AppDelegate']['ThreeClass'])
    assert_equal(dependencies['TwoClass'], dependencies['ThreeClass'])

  end

  def test_swift_with_spaces_in_name
    generator = ObjCDependencyTreeGenerator.new({
                                                    :derived_data_paths => ['./test/fixtures/swift-with-spaces'],
                                                    :derived_data_project_pattern => '*',
                                                    :swift_dependencies => true,
                                                    :project_name => ""
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['SimpleModel'])
    assert_not_nil(dependencies['ViewController']['SimpleModel'])

  end

  def test_objc_with_spaces_in_name
    generator = ObjCDependencyTreeGenerator.new({
                                                    :derived_data_paths => ['./test/fixtures/objc-with-spaces'],
                                                    :derived_data_project_pattern => '*',
                                                    :project_name => "",
                                                    :use_dwarf => true
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['SimpleModel'])
    assert_not_nil(dependencies['ViewController']['SimpleModel'])

  end


end