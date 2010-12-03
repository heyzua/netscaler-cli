require 'netscaler/clitemplate'
require 'netscaler/vserver/executor'

module Netscaler::VServer
  class CLI < Netscaler::CLITemplate
    def initialize(args)
      super('vserver', args)
    end

    def create_executor(client)
      Netscaler::VServer::Executor.new(host, client)
    end

    def interface_header(opts)
      opts.banner = "Usage: #{File.basename($0)} [OPTIONS] [VSERVER]"
      opts.separator <<DESC
Description:
    This is a tool for enabling and disabling a virtual server in a Netscaler
    load balancer.  The name of the virtual server is required, as is the
    address of the Netscaler load balancer.

    By default, this script will tell you what its current status of the
    virtual server is.

    If you want to list all of the virtual servers, use the --list flag with no
    server argument.

Options:
DESC
    end

    def interface_actions(opts)
      opts.separator "   Actions: "
      opts.on('-e', '--enable',
              "Enables the given virtual server.") do |e|
        options[:action] << :enable
      end
      opts.on('-d', '--disable',
              "Disables the given virtual server.") do |d|
        options[:action] << :disable
      end
      opts.on('-b', '--bind POLICY_NAME',
              "Binds a policy of a given name to a",
              "virtual server.") do |b|
        options[:action] << :bind
        options[:policy_name] = b
      end
      opts.on('-p', '--priority NUMBER', Integer,
              "The priority to bind the policy with.",
              "Used only with the --bind flag.") do |p|
        options[:priority] = p
      end
      opts.on('-u', '--unbind POLICY_NAME',
              "Unbinds a policy of a given name to a",
              "virtual server.") do |u|
        options[:action] << :unbind
        options[:policy_name] = u
      end
      opts.on('-l', '--list',
              "List all of the virtual servers in the environment.") do |l|
        options[:action] << :list
      end
      opts.separator ""
    end

    def requires_argument?
      false
    end

    def validate_noargs
      if !options[:action].include?(:list)
        raise Netscaler::ConfigurationError.new("No hosts specified to act on.")
      end
    end

    def validate_args(args)
      super(args)

      if options[:action][0] == :bind
        if options[:priority].nil?
          options[:priority] = 1
        elsif options[:priority] <= 0
          raise Netscaler::ConfigurationError.new("The --priority must be greater than 0")
        end
      else
        if options[:priority]
          raise Netscaler::ConfigurationError.new("The --priority flag can only specified with the --bind option")
        end
      end
    end
  end # CLI
end
