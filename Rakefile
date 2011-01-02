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
  gem.version = File.exist?('VERSION') ? File.read('VERSION') : ""
  gem.homepage = "https://github.com/Ennova/acts_as_importable"
  gem.license = "MIT"
  gem.summary = %Q{Makes your model importable from .csv and exportable to .csv}
  gem.description = %Q{Use this gem to add import/export to .csv functionality to your activerecord models}
  gem.email = "jagdeepkh@gmail.com"
  gem.authors = ["Jagdeep Singh"]
  gem.files.exclude 'test'
  gem.files.exclude '.rvmrc'
  gem.files.exclude '.document'
  gem.test_files.exclude 'test'
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "acts_as_importable #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
