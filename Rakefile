$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'fileutils'
require 'rake'
require 'rubygems'
require 'rspec/core/rake_task'
require 'jabber-tee/version'

task :default => :spec

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['-b', '-c', '-f', 'p']
  t.fail_on_error = false
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name           = 'netscaler-cli'
    gem.version        = Netscaler::Version.to_s
    gem.executables    = %W{netscaler-vserver netscaler-service netscaler-server}
    gem.summary        = 'Simple command line utilities for interacting remotely with a Netscaler load balancer.'
    gem.description    = 'This gem installs several simple command line utilities locally.  It uses the NSConfig.wsdl SOAP interface for remote access.'
    gem.email          = ['madeonamac@gmail.com']
    gem.authors        = ['Gabe McArthur']
    gem.homepage       = 'http://github.com/gabemc/netscaler-cli'
    gem.files          = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    
    gem.add_dependency    'highline',   '>=1.5.2'
    gem.add_dependency    'log4r',      '>=1.1.7'
    gem.add_dependency    'savon',      '>=0.7.9'
    
    gem.add_development_dependency 'rspec', '>=1.3.0'
  end
rescue LoadError
  puts "Jeweler or dependencies are not available.  Install it with: sudo gem install jeweler"
end

desc "Deploys the gem to rubygems.org"
task :gem => :release do
  system("gem build netscaler-cli.gemspec")
  system("gem push netscaler-cli-#{Netscaler::Version.to_s}.gem")
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end

desc "Cleans the gem files up."
task :clean do
  FileUtils.rm(Dir.glob('*.gemspec'))
  FileUtils.rm(Dir.glob('*.gem'))
end
