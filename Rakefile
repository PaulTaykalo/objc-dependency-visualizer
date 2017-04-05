require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*test.rb'
end

desc 'Run tests'
task :default => :test