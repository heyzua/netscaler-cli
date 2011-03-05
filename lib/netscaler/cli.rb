require 'netscaler/errors'
require 'netscaler/version'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'netscaler/config'
require 'choosy'

module Netscaler
  class CLI

    def initialize(args)
      @args = argdup
    end

    def execute!
      command.parse!(@args)
    end
    
    protected
    def command
      @command ||= Choosy::SuperCommand.new :netscaler do
        printer :standard, :color => true, :headers => [:bold, :blue], :max_width => 80

        summary "This is a command line tool for interacting with Netscaler load balancer"
        header 'DESCRIPTION'
        para "There are several subcommands to do various things with the load balancer. Try 'netscaler help SUBCOMMAND' for more information about the particular"
        para "Note that you can supply a configuration file, which would normally be found under ~/.netscaler-cli.yml. That file describes the relationship between your Netscaler load balancers and the aliases, usernames, and passwords that you supply for them. The file is in the general format:"
        para "  netscaler.host.name.com:
    alias: is_optional
    usernamd: is_required
    password: is_optional_but_querried_if_not_found"
        
        # COMMANDS
        header 'COMMANDS'
        command servers
        command vservers
        command services
        para
        help

        # OPTIONS
        header 'GLOBAL OPTIONS'
        string :netscaler, "The IP Address, hostname, or alias in the config file of the Netscaler load balancer. This is required." do
          depends_on :config
          required

          validate do |arg, options|
            reader = Netscaler::ConfigurationReader.new(options[:config])
            config = reader[arg]
            if config.nil?
              die "the Netscaler address '#{arg}' is not defined in the configuration file"
            else
              options[:netscaler] = config
            end
          end
        end
        yaml :config, "The path to the netscaler configuration file. By default, it is ~/.netscaler-cli.yml" do
          default File.join(ENV['HOME'], '.netscaler-cli.yml')
        end
        
        header 'INFORMATIVE'
        boolean_ :debug, "Print extra debug information"
        boolean_ :json, "Prints out JSON instead of textual data"
        version Netscaler::Version.to_s
      end
    end#command

    def servers
      Choosy::Command.new :server do |s|
        summary "Enables, disbles, or lists servers in the load balancer"
        header 'DESCRIPTION'
        para "This is a tool for enabling and disabling a server in a Netscaler load balancer.  The name of the server is required, as is the address of the Netscaler load balancer."
        para "By default, this command will tell you what the current status of the server is."
        para "If you want to list all of the services, use the --list flag."
          
        header 'OPTIONS'
        enum :action, [:enable, :disable, :list, :status], "Either [enable, disable, list]. 'list' will ignore additional arguments. Default action is 'status'" do
          default :status
        end
        arguments do
          count 0..1 #:at_least => 0, :at_most => 1
          metaname 'SERVER'
          validate do |args, options|
            if arglength == 0
              die "No server given to act upon" unless options[:action] == :list
            end
          end
        end
      end
    end

    def vservers
      Choosy::Command.new :vserver do
        summary "Enables, disables, binds or unbinds policies, or lists virtual servers."
        header 'DESCRIPTION'
        para "This is a tool for acting upon virtual servers (VIPs) in a Netscaler load balancer. The name of the virtual server is required."
        para "By default, this command will tell you what the current status of the server is."
        para "If you want to list all of the virtual servers, use the --list flag."

        header 'OPTIONS'
        enum :action, [:enable, :disable, :list, :bind, :unbind, :status], "Either [enable, disable, list, bind, unbind, status]. 'bind' and 'unbind' require the additional '--policy' flag. 'list' will ignore additional arguments. Default action is 'status'." do
          default :status
        end
        string :policy, "The name of the policy to bind/unbind." do
          depends_on :action
          validate do |arg, options|
            die "only used with bind/unbind" unless [:bind, :unbind].include?(options[:action])
          end
        end
        integer :Priority, "The integer priority of the policy to bind with. Default is 100." do
          depends_on :action, :policy
          default 100
          validate do |arg, options|
            die "only used with the bind action" unless options[:action] == :bind
          end
        end
        arguments do |a|
          count 0..1 #:at_least => 0, :at_most => 1
          metaname 'SERVER'
          validate do |args, options|
            if arglength == 0
              die "no virtual server given to act upon" unless option[:action] == :list
            end
          end
        end
      end
    end

    def services
      Choosy::Command.new :service do
        summary "Enables, disables, binds or unbinds from a virtual server, a given service."
        header 'DESCRIPTION'
        para "This is a tool for enabling and disabling services in a Netscaler load balancer.  The name of the service is required, as is the address of the Netscaler load balancer."
        
        header 'OPTIONS'
        enum :action, [:enable, :disable, :bind, :unbind, :status], "Either [enable, disable, bind, unbind, status] of a service. 'bind' and 'unbind' require the '--vserver' flag. Default is 'status'." do
          default :status
        end
        string :vserver, "The virtual server to bind/unbind this service to/from." do
          depends_on :action
          validate do |args, options|
            die "only used with bind/unbind" unless [:bind, :unbind].include?(options[:action])
          end
        end
        arguments do
          count 0..1 #:at_least => 0, :at_most => 1
          metaname 'SERVICE'
          validate do |args, options|
            if arglength == 0
              die "No services given to act on" unless option[:action] == :list
            end
          end
        end
      end
    end
  end
end
