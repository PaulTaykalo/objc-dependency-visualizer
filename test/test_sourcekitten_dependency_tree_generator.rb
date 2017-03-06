require 'test/unit'
require 'sourcekitten_dependencies_generator'

class SwiftDependencyTreeGeneratorTest < Test::Unit::TestCase
  def test_links_generation
    generator = ObjCDependencyTreeGenerator.new({})
    assert_equal generator.find_dependencies, {}
  end

  def test_simple_objects
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['AppDelegate'])
    assert_not_nil(dependencies['MainClass'])
    assert_not_nil(dependencies['SubclassOfSubclass'])
    assert_not_nil(dependencies['Subclass'])

  end


  def test_simple_inheritance
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

  def test_extensions
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['ProtocolToExtend'])
    assert_not_nil(dependencies['MainClass']["ProtocolToExtend"])

  end

  def test_structs
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['SimpleStruct'])
    assert_not_nil(dependencies['StructWithProtocols']["ProtocolToExtend"])
    assert_not_nil(dependencies['StructWithProtocols']["AwesomeProtocol"])
  end

  def test_interfile_dependencies
    generator = ObjCDependencyTreeGenerator.new({
                                                    :sourcekitten_dependencies_file => './test/fixtures/sourcekitten/sourcekitten.json',
                                                })
    dependencies = generator.find_dependencies
    assert_not_equal(dependencies, {})
    assert_not_nil(dependencies['SecondClass'])
    assert_not_nil(dependencies['SecondClassProtocol'])
    assert_not_nil(dependencies['SecondClass']["MainClass"])
    assert_not_nil(dependencies['SecondClass']["SecondClassProtocol"])
    assert_not_nil(dependencies['SecondClass']["AwesomeProtocol"])
  end


end