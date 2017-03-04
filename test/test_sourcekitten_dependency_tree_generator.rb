require 'test/unit'
require 'sourcekitten_dependencies_generator'

class SwiftDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = ObjCDependencyTreeGenerator.new({})
    assert_equal generator.find_dependencies, {}
  end

  def test_swift_simple_inheritance
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])

  end


  # def test_swift_xcode7_out
  #   generator = ObjCDependencyTreeGenerator.new({
  #                                                   :search_directories => './test/fixtures/swift-xcode-7-out',
  #                                                   :swift_dependencies => true
  #                                               })
  #   dependencies = generator.find_dependencies
  #   assert_not_equal(dependencies, {})
  #   assert_not_nil(dependencies['AppDelegate'])
  #   assert_not_nil(dependencies['AppDelegate']['Database'])
  #   assert_not_nil(dependencies['AppDelegate']['NoteViewController_iOS'])
  #   assert_not_nil(dependencies['Note']['Notebook'])
  #   assert_not_nil(dependencies['NotesViewController_iOS']['AppDelegate'])

  # end

  # def test_multiple_dirs
  #   generator = ObjCDependencyTreeGenerator.new({
  #                                                   :search_directories => ['./test/fixtures/swift-xcode-7-out', './test/fixtures/swift-simple-inheritance/x86_64'],
  #                                                   :swift_dependencies => true
  #                                               })
  #   dependencies = generator.find_dependencies
  #   assert_not_equal(dependencies, {})
  #   assert_not_nil(dependencies['AppDelegate'])
  #   assert_not_nil(dependencies['AppDelegate']['Database'])
  #   assert_not_nil(dependencies['AppDelegate']['NoteViewController_iOS'])
  #   assert_not_nil(dependencies['Note']['Notebook'])
  #   assert_not_nil(dependencies['NotesViewController_iOS']['AppDelegate'])
  #   assert_not_nil(dependencies['MasterViewController']['DetailViewController'])
  #   assert_not_nil(dependencies['AppDelegate']['TwoClass'])
  #   assert_not_nil(dependencies['AppDelegate']['ThreeClass'])
  # end

  # def test_multiple_targets
  #   generator = ObjCDependencyTreeGenerator.new({
  #                                                   :derived_data_paths => ['./test/fixtures/multiple-targets'],
  #                                                   :target_names => ['iAsyncWeather', 'JFFAsyncOperations'],
  #                                                   :use_dwarf => true
  #                                               })
  #   dependencies = generator.find_dependencies
  #   assert_not_equal(dependencies, {})
  #   assert_not_nil(dependencies['AWOperationsFactory'])
  #   assert_not_nil(dependencies['AWOperationsFactory']['JFFCancelAsyncOperation'])
  #   assert_not_nil(dependencies['JFFAsyncOperationHelpers']['JFFCancelAsyncOperation'])

  # end



  # def test_swift_with_spaces_in_name
  #   generator = ObjCDependencyTreeGenerator.new({
  #                                                   :derived_data_paths => ['./test/fixtures/swift-with-spaces'],
  #                                                   :derived_data_project_pattern => '*',
  #                                                   :swift_dependencies => true,
  #                                                   :project_name => ""
  #                                               })
  #   dependencies = generator.find_dependencies
  #   assert_not_equal(dependencies, {})
  #   assert_not_nil(dependencies['AppDelegate'])
  #   assert_not_nil(dependencies['SimpleModel'])
  #   assert_not_nil(dependencies['ViewController']['SimpleModel'])

  # end

  # def test_objc_with_spaces_in_name
  #   generator = ObjCDependencyTreeGenerator.new({
  #                                                   :derived_data_paths => ['./test/fixtures/objc-with-spaces'],
  #                                                   :derived_data_project_pattern => '*',
  #                                                   :project_name => "",
  #                                                   :use_dwarf => true
  #                                               })
  #   dependencies = generator.find_dependencies
  #   assert_not_equal(dependencies, {})
  #   assert_not_nil(dependencies['AppDelegate'])
  #   assert_not_nil(dependencies['SimpleModel'])
  #   assert_not_nil(dependencies['ViewController']['SimpleModel'])

  # end


end