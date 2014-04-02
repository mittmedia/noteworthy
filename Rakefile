# encoding: utf-8

require 'rubygems'
require "bundler/gem_tasks"

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.title = "releasenoter"
end
task :doc => :rdoc

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'noteworthy'
Noteworthy::Tasks.new

task :test    => :spec
task :default => :spec
