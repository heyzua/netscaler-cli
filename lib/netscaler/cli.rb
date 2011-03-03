require 'netscaler/errors'
require 'netscaler/version'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'netscaler/config'
require 'choosy'

module Netscaler
  class CLI

    def initialize(args)
      @args = args.dup
    end

    def execute!
      command.parse!(@args)
    end
    
    protected
    def command
      @command ||= Choosy::SuperCommand.new :netscaler do |n|
        n.printer :standard, :color => true, :headers => [:bold, :blue], :max_width => 80

        n.summary "This is a command line tool for interacting with Netscaler load balancers."
        n.header 'DESCRIPTION'
        n.para "There are several subcommands to do various things with the load balancer. Try 'netscaler help SUBCOMMAND' for more information about the particulars."
        n.para "Note that you can supply a configuration file, which would normally be found under ~/.netscaler-cli.yml. That file describes the relationship between your Netscaler load balancers and the aliases, usernames, and passwords that you supply for them. The file is in the general format:"
        n.para "  netscaler.host.name.com:
    alias: is_optional
    usernamd: is_required
    password: is_optional_but_querried_if_not_found"
        
        # COMMANDS
        n.header 'COMMANDS'
        n.command servers
        n.command vservers
        n.command services
        n.para
        n.help

        # OPTIONS
        n.header 'GLOBAL OPTIONS'
        n.string :netscaler, "The IP Address, hostname, or alias in the config file of the Netscaler load balancer. This is required." do |netscaler|
          netscaler.depends_on :config
          netscaler.required

          netscaler.validate do |arg, options|
            reader = Netscaler::ConfigurationReader.new(options[:config])
            config = reader[arg]
            if config.nil?
              netscaler.fail "the Netscaler address '#{arg}' is not defined in the configuration file"
            else
              options[:netscaler] = config
            end
          end
        end
        n.yaml :config, "The path to the netscaler configuration file. By default, it is ~/.netscaler-cli.yml" do |config|
          config.default File.join(ENV['HOME'], '.netscaler-cli.yml')
        end
        
        n.header 'INFORMATIVE'
        n.boolean_ :debug, "Print extra debug information"
        n.boolean_ :json, "Prints out JSON instead of textual data"
        n.version Netscaler::Version.to_s
      end
    end#command

    def servers
      Choosy::Command.new :server do |s|
        s.summary "Enables, disbles, or lists servers in the load balancer"
        s.header 'DESCRIPTION'
        s.para "This is a tool for enabling and disabling a server in a Netscaler load balancer.  The name of the server is required, as is the address of the Netscaler load balancer."
        s.para "By default, this command will tell you what the current status of the server is."
        s.para "If you want to list all of the services, use the --list flag."
          
        s.header 'OPTIONS'
        s.enum :action, [:enable, :disable, :list, :status], "Either [enable, disable, list]. 'list' will ignore additional arguments. Default action is 'status'" do |a|
          a.default :status
        end
        s.arguments do |a|
          a.count 0..1 #:at_least => 0, :at_most => 1
          a.metaname 'SERVER'
          a.validate do |args, options|
            if args.length == 0
              a.fail "No server given to act upon" unless options[:action] == :list
            end
          end
        end
      end
    end

    def vservers
      Choosy::Command.new :vserver do |v|
        s.summary "Enables, disables, binds or unbinds policies, or lists virtual servers."
        s.header 'DESCRIPTION'
        s.para "This is a tool for acting upon virtual servers (VIPs) in a Netscaler load balancer. The name of the virtual server is required."
        s.para "By default, this command will tell you what the current status of the server is."
        s.para "If you want to list all of the virtual servers, use the --list flag."

        s.header 'OPTIONS'
        s.enum :action, [:enable, :disable, :list, :bind, :unbind, :status], "Either [enable, disable, list, bind, unbind, status]. 'bind' and 'unbind' require the additional '--policy' flag. 'list' will ignore additional arguments. Default action is 'status'." do |a|
          a.default :status
        end
        s.string :policy, "The name of the policy to bind/unbind." do |p|
          p.depends_on :action
          p.validate do |arg, options|
            p.fail "only used with bind/unbind" unless [:bind, :unbind].include?(options[:action])
          end
        end
        s.integer :Priority, "The integer priority of the policy to bind with. Default is 100." do |p|
          p.depends_on :action, :policy
          p.default 100
          p.validate do |arg, options|
            p.fail "only used with the bind action" unless options[:action] == :bind
          end
        end
        s.arguments do |a|
          a.count 0..1 #:at_least => 0, :at_most => 1
          a.metaname 'SERVER'
          a.validate do |args, options|
            if args.length == 0
              a.fail "no virtual server given to act upon" unless option[:action] == :list
            end
          end
        end
      end
    end

    def services
      Choosy::Command.new :service do |s|
        s.summary "Enables, disables, binds or unbinds from a virtual server, a given service."
        s.header 'DESCRIPTION'
        s.para "This is a tool for enabling and disabling services in a Netscaler load balancer.  The name of the service is required, as is the address of the Netscaler load balancer."
        
        s.header 'OPTIONS'
        s.enum :action, [:enable, :disable, :bind, :unbind, :status], "Either [enable, disable, bind, unbind, status] of a service. 'bind' and 'unbind' require the '--vserver' flag. Default is 'status'." do |a|
          a.default :status
        end
        s.string :vserver, "The virtual server to bind/unbind this service to/from." do |v|
          v.depends_on :action
          v.validate do |args, options|
            v.fail "only used with bind/unbind" unless [:bind, :unbind].include?(options[:action])
          end
        end
        s.arguments do |a|
          a.count 0..1 #:at_least => 0, :at_most => 1
          a.metaname 'SERVICE'
          a.validate do |args, options|
            if args.length == 0
              a.fail "No services given to act on" unless option[:action] == :list
            end
          end
        end
      end
    end
  end
end
