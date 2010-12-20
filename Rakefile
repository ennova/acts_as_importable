require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "acts_as_importable"
  gem.homepage = "https://Ennova@github.com/Ennova/acts_as_importable.git"
  gem.license = "MIT"
  gem.summary = %Q{Makes your model importable from .csv and exportable to .csv}
  gem.description = %Q{Use this gem to add import/export to .csv functionality to your activerecord models}
  gem.email = "jagdeepkh@gmail.com"
  gem.authors = ["Jagdeep Singh"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'fastercsv', "~> 1.5.3"
  gem.add_runtime_dependency "activerecord", "~> 3.0.3"
  gem.add_runtime_dependency "actionpack", "~> 3.0.3"
  gem.add_development_dependency "rspec", "~> 2.2.0"
  gem.add_development_dependency "bundler", "~> 1.0.0"
  gem.add_development_dependency "jeweler", "~> 1.5.2"
  gem.add_development_dependency "rcov", ">= 0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec'
require "rspec/core/rake_task"
desc "Run all rspec examples under spec"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_path = 'bin/rspec'
  t.rspec_opts = %w[--color]
  t.verbose = false
end
require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "acts_as_importable #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
