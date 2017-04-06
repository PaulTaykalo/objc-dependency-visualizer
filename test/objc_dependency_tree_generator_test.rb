require 'test/unit'
require 'objc_dependency_tree_generator'

class ObCDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = DependencyTreeGenerator.new({})
    tree = generator.build_dependency_tree
    assert(tree.isEmpty?)
  end

  def test_swift_simple_inheritance
    generator = DependencyTreeGenerator.new(
      search_directories: './test/fixtures/swift-simple-inheritance/x86_64',
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('TwoClass'))
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.connected?('MasterViewController', 'DetailViewController'))
    assert(tree.connected?('AppDelegate', 'TwoClass'))
    assert(tree.connected?('AppDelegate', 'ThreeClass'))
    assert(tree.connected?('AppDelegate', 'ThreeClass'))
    # assert_equal(dependencies['TwoClass'], dependencies['ThreeClass'])

  end


  def test_swift_xcode7_out
    generator = DependencyTreeGenerator.new(
      search_directories: './test/fixtures/swift-xcode-7-out',
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.connected?('AppDelegate', 'Database'))
    assert(tree.connected?('AppDelegate', 'NoteViewController_iOS'))
    assert(tree.connected?('Note', 'Notebook'))
    assert(tree.connected?('NotesViewController_iOS', 'AppDelegate'))

  end

  def test_multiple_dirs
    generator = DependencyTreeGenerator.new(
      search_directories: ['./test/fixtures/swift-xcode-7-out', './test/fixtures/swift-simple-inheritance/x86_64'],
      swift_dependencies: true
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.connected?('AppDelegate', 'Database'))
    assert(tree.connected?('AppDelegate', 'NoteViewController_iOS'))
    assert(tree.connected?('Note', 'Notebook'))
    assert(tree.connected?('NotesViewController_iOS', 'AppDelegate'))
    assert(tree.connected?('MasterViewController', 'DetailViewController'))
    assert(tree.connected?('AppDelegate', 'TwoClass'))
    assert(tree.connected?('AppDelegate', 'ThreeClass'))
  end

  def test_multiple_targets
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/multiple-targets'],
      target_names: ['iAsyncWeather', 'JFFAsyncOperations'],
      use_dwarf: true
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AWOperationsFactory'))
    assert(tree.connected?('AWOperationsFactory', 'JFFCancelAsyncOperation'))
    assert(tree.connected?('JFFAsyncOperationHelpers', 'JFFCancelAsyncOperation'))
  end


  def test_swift_with_spaces_in_name
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/swift-with-spaces'],
      derived_data_project_pattern: '*',
      swift_dependencies: true,
      project_name: ""
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.isRegistered?('SimpleModel'))
    assert(tree.connected?('ViewController', 'SimpleModel'))

  end

  def test_objc_with_spaces_in_name
    generator = DependencyTreeGenerator.new(
      derived_data_paths: ['./test/fixtures/objc-with-spaces'],
      derived_data_project_pattern: '*',
      project_name: "",
      use_dwarf: true
    )
    tree = generator.build_dependency_tree
    assert(!tree.isEmpty?)
    assert(tree.isRegistered?('AppDelegate'))
    assert(tree.isRegistered?('SimpleModel'))
    assert(tree.connected?('ViewController', 'SimpleModel'))

  end


end