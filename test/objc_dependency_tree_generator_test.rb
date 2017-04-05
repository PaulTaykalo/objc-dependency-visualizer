require 'test/unit'
require 'objc_dependency_tree_generator'

class ObCDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert_true(tree.isEmpty?)
  end

  def test_swift_simple_inheritance
    generator = DependencyTreeGenerator.new(
      search_directories: './test/fixtures/swift-simple-inheritance/x86_64',
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('TwoClass'))
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.connected?('MasterViewController', 'DetailViewController'))
    assert_true(tree.connected?('AppDelegate', 'TwoClass'))
    assert_true(tree.connected?('AppDelegate', 'ThreeClass'))
    assert_true(tree.connected?('AppDelegate', 'ThreeClass'))
    # assert_equal(dependencies['TwoClass'], dependencies['ThreeClass'])

  end


  def test_swift_xcode7_out
    generator = DependencyTreeGenerator.new(
      search_directories: './test/fixtures/swift-xcode-7-out',
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.connected?('AppDelegate', 'Database'))
    assert_true(tree.connected?('AppDelegate', 'NoteViewController_iOS'))
    assert_true(tree.connected?('Note', 'Notebook'))
    assert_true(tree.connected?('NotesViewController_iOS', 'AppDelegate'))

  end

  def test_multiple_dirs
    generator = DependencyTreeGenerator.new(
      search_directories: ['./test/fixtures/swift-xcode-7-out', './test/fixtures/swift-simple-inheritance/x86_64'],
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.connected?('AppDelegate', 'Database'))
    assert_true(tree.connected?('AppDelegate', 'NoteViewController_iOS'))
    assert_true(tree.connected?('Note', 'Notebook'))
    assert_true(tree.connected?('NotesViewController_iOS', 'AppDelegate'))
    assert_true(tree.connected?('MasterViewController', 'DetailViewController'))
    assert_true(tree.connected?('AppDelegate', 'TwoClass'))
    assert_true(tree.connected?('AppDelegate', 'ThreeClass'))
  end

  def test_multiple_targets
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/multiple-targets'],
      target_names: ['iAsyncWeather', 'JFFAsyncOperations'],
      use_dwarf: true
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AWOperationsFactory'))
    assert_true(tree.connected?('AWOperationsFactory', 'JFFCancelAsyncOperation'))
    assert_true(tree.connected?('JFFAsyncOperationHelpers', 'JFFCancelAsyncOperation'))
  end


  def test_swift_with_spaces_in_name
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/swift-with-spaces'],
      derived_data_project_pattern: '*',
      swift_dependencies: true,
      project_name: ""
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.isRegistered?('SimpleModel'))
    assert_true(tree.connected?('ViewController', 'SimpleModel'))

  end

  def test_objc_with_spaces_in_name
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/objc-with-spaces'],
      derived_data_project_pattern: '*',
      project_name: "",
      use_dwarf: true
    )
    tree = generator.build_dependency_tree
    assert_false(tree.isEmpty?)
    assert_true(tree.isRegistered?('AppDelegate'))
    assert_true(tree.isRegistered?('SimpleModel'))
    assert_true(tree.connected?('ViewController', 'SimpleModel'))

  end


end