require "rubygems"
require "rake"
require "rake/testtask"

desc "Run tests"
Rake::TestTask.new "test" do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :default => 'test'
