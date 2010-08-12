$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'fileutils'
require 'rake'
require 'rubygems'
require 'spec/rake/spectask'
require 'netscaler/version'

task :default => :spec

desc "Run the RSpec tests"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-b', '-c', '-f', 'p']
  t.fail_on_error = false
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version        = Netscaler::Version.to_s
    gem.name           = 'netscaler-cli'
    gem.executables    = %W{netscaler-vip netscaler-responder}
    gem.summary        = 'Simple command line utilities for interacting with a Netscaler load balancer.'
    gem.description    = 'TODO'
    gem.email          = ['madeonamac@gmail.com']
    gem.authors        = ['Gabe McArthur']
    
    gem.add_dependency    'highline',   '>=1.5.2'
    gem.add_dependency    'log4r',      '>=1.1.7'
    gem.add_dependency    'savon',      '>=0.7.9'
    
    gem.add_development_dependency 'rspec', '>=1.3.0'
  end
rescue LoadError
  puts "Jeweler or dependencies are not available.  Install it with: sudo gem install jeweler"
end

task :clean do
  FileUtils.rm(Dir.glob('*.gemspec'))
  FileUtils.rm(Dir.glob('*.gem'))
end
