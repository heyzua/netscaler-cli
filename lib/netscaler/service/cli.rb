require 'netscaler/clitemplate'
require 'netscaler/service/executor'

module Netscaler::Service
  class CLI < Netscaler::CLITemplate
    def initialize(args)
      super('service', args)
    end

    def create_executor(client)
      Netscaler::Service::Executor.new(host, client)
    end

    def interface_header(opts)
      opts.banner = "Usage: #{File.basename($0)} [OPTIONS] SERVICE"
      opts.separator <<DESC
Description:
    This is a tool for enabling and disabling services in a Netscaler
    load balancer.  The name of the service is required, as is the
    address of the Netscaler load balancer.

Options:
DESC
    end

    def interface_actions(opts)
      opts.separator "   Actions: "
      opts.on('-e', '--enable',
              "Enables the given service.") do |e|
        options[:action] << :enable
      end
      opts.on('-d', '--disable',
              "Disables the given service.") do |d|
        options[:action] << :disable
      end
      opts.on('-b', '--bind VSERVER',
              "Binds a service to a virtual server.") do |b|
        options[:action] << :bind
        options[:vserver] = b
      end
      opts.on('-u', '--unbind VSERVER',
              "Unbinds a serivce to a virtual server.") do |u|
        options[:action] << :unbind
        options[:vserver] = u
      end
      opts.separator ""
    end
  end # CLI
end
