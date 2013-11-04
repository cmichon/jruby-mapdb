%w[rubygems rake rake/testtask].map &method(:require) 

desc 'Run tests'
Rake::TestTask.new 'test' do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

def runme(iterations)
  @f = Tempfile.new('bmdb')
  @db = Jruby::Mapdb::DB.new(@f.path)
  @db.tree :Numbers
  i = 1
  iterations.times do
    Numbers[i] = i
    i += 1
  end
  @db.close
  File.delete(@f.path + '.p')
  Object.send(:remove_const, :Numbers)
end

desc 'Run benchmarks'
task :bm do |t|
  $: << File.expand_path('../lib', __FILE__)
  %w[benchmark jruby-mapdb tempfile].map &method(:require) 
  Benchmark.bm(8) do |x|
    x.report("1k")   { runme      1_000 }
    x.report("10k")  { runme     10_000 }
    x.report("100k") { runme    100_000 }
    x.report("1M")   { runme  1_000_000 }
    x.report("10M")  { runme 10_000_000 }
  end
end

task :default => 'test'
