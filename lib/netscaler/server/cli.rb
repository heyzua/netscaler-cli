require 'netscaler/clitemplate'
require 'netscaler/server/executor'

module Netscaler::Server
  class CLI < Netscaler::CLITemplate
    def initialize(args)
      super('server', args)
    end

    def create_executor(client)
      Netscaler::Server::Executor.new(host, client)
    end

    def interface_header(opts)
      opts.banner = "Usage: #{File.basename($0)} [OPTIONS] SERVER"
      opts.separator <<DESC
Description:
    This is a tool for enabling and disabling a server in a Netscaler
    load balancer.  The name of the server is required, as is the
    address of the Netscaler load balancer.

    By default, this script will tell you what its current status of the
    server is.

Options:
DESC
    end

    def interface_actions(opts)
      opts.separator "   Actions: "
      opts.on('-e', '--enable',
              "Enables the given server.") do |e|
        options[:action] << :enable
      end
      opts.on('-d', '--disable',
              "Disables the given server.") do |d|
        options[:action] << :disable
      end
      opts.separator ""
    end
  end # CLI
end
