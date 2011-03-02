require 'netscaler/errors'
require 'netscaler/version'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'netscaler/config'
require 'choosy'

module Netscaler
  class CLI
    
    protected
    def command
      @command ||= Choosy::SuperCommand.new :netscaler do |n|
        n.summary "This is a command line tool for interacting with Netscaler load balancers."
        n.desc "There are several subcommands to do various things with the load balancer. Try 'netscaler help SUBCOMMAND' for more information about the particulars.

Note that you can supply a configuration file, which would normally be found under ~/.netscaler-cli.yml. That file describes the relationship between your Netscaler load balancers and the aliases, usernames, and passwords that you supply for them. The file is in the general format:
  netscaler.host.name.com:
    alias: is_optional
    usernamd: is_required
    password: is_optional_but_querried_if_not_found"
        
        n.separator 'COMMANDS'
        n.command :server do |s|
          
        end
        n.help

        n.separator 'GLOBAL OPTIONS'
        n.string :netscaler, "The IP Address, hostname, or alias in the config file of the Netscaler load balancer. This is required." do |netscaler|
          netscaler.required
        end
        n.string :config, "The path to the netscaler configuration file. By default, it is ~/.netscaler-cli.yml" do |config|
          config.default File.join(ENV['HOME'], '.netscaler-cli.yml')
          config.validate do |c|
            if !File.exists?(c)
              config.fail "config file doesn't exist: #{c}"
            end
          end
        end
        
        n.separator 'INFORMATIVE'
        n.boolean_ :debug, "Print extra debug information"
        n.boolean_ :json, "Prints out JSON instead of textual data"
        n.version Netscaler::Version.to_s
      end
    end#command
  end
end
