require 'test/unit'
require 'sourcekitten_dependencies_generator'

class SwiftDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = ObjCDependencyTreeGenerator.new({})
    assert_equal generator.find_dependencies, {}
  end

  def test_swift_simple_objects
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['MainClass'])
    assert_not_nil(dependencies['SubclassOfSubclass'])
    assert_not_nil(dependencies['Subclass'])
    assert_not_nil(dependencies['ViewController'])

  end


  def test_swift_simple_inheritance
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['Subclass']["MainClass"])
    assert_not_nil(dependencies['SubclassOfSubclass']["Subclass"])
    assert_not_nil(dependencies['SubclassOfSubclass']["AwesomeProtocol"])
    assert_not_nil(dependencies['SubProtocol']["AwesomeProtocol"])
    assert_not_nil(dependencies['SubclassOfMainClass']["MainClass"])
    assert_not_nil(dependencies['SubclassOfMainClass']["SubProtocol"])

  end

  def test_swift_extensions
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['ProtocolToExtend'])
    assert_not_nil(dependencies['MainClass']["ProtocolToExtend"])

  end


end