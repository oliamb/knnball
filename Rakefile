require 'rake/testtask'

Rake::TestTask.new(:test) do |tt|
  tt.test_files = FileList['test/spec/*_spec.rb', 'test/units/*_test.rb']
  tt.verbose = true
end

task :default => :test
