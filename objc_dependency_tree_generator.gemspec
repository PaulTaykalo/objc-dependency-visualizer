Gem::Specification.new do |s|
  s.name        = 'objc-dependency-tree-generator'
  s.version     = '0.1.0'
  s.date        = '2017-10-17'
  s.summary     = 'Objective-C and Swift dependency tree generator'
  s.description = <<-THEEND
Tool that allows to generate Objective-C and Swift dependency tree from object files
For usages examples run:
objc_dependency_tree_generator -h
THEEND
  s.authors     = ['Paul Taykalo']
  s.email       = 'tt.kilew@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    =
      'https://github.com/PaulTaykalo/objc-dependency-visualizer'
  s.license       = 'MIT'
  s.executables << 'objc_dependency_tree_generator'
end