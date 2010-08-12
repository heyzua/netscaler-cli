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
      opts.banner = "Usage: #{File.basename($0)} [OPTIONS] VSERVER"
      opts.separator <<DESC
Description:
    This is a tool for enabling and disabling virtual server in a Netscaler
    load balancer.  The name of the virtual server is required, as is the
    address of the Netscaler load balancer.

    By default, this script will tell you what its current status of the
    virtual server is.

Options:
DESC
    end

    def interface_actions(opts)
      opts.separator "   Actions: "
      opts.on('-e', '--enable',
              "Enables the given virtual server.") do |e|
        options[:action][:enable] = nil
      end
      opts.on('-d', '--disable',
              "Disables the given virtual server.") do |d|
        options[:action][:disable] = nil
      end
      opts.on('-b', '--bind POLICY_NAME',
              "Binds a policy of a given name to a virtual server.") do |b|
        options[:action][:bind] = b
      end
      opts.on('-u', '--unbind POLICY_NAME',
              "Unbinds a policy of a given name to a virtual server.") do |u|
        options[:action][:unbind] = u
      end
      opts.separator ""
    end
  end # CLI
end
