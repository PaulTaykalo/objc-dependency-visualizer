Gem::Specification.new do |s|
  s.name        = 'objc-dependency-tree-generator'
  s.version     = '0.0.4'
  s.date        = '2015-08-20'
  s.summary     = 'Objective-C and Swift dependency tree generator'
  s.description = <<-THEEND
Tool that allows to generate Objective-C and Swift dependency tree from object files
For usages examples run:
objc_dependency_tree_generator -h
THEEND
  s.authors     = ['Paul Taykalo']
  s.email       = 'tt.kilew@gmail.com'
  s.files       = ['lib/objc_dependency_tree_generator.rb',
                   'lib/objc_dependency_tree_generator_helper.rb',
                   'lib/objc_dependencies_generator.rb',
                   'lib/swift_dependencies_generator.rb'
  ]
  s.homepage    =
      'https://github.com/PaulTaykalo/objc-dependency-visualizer'
  s.license       = 'MIT'
  s.executables << 'objc_dependency_tree_generator'
end