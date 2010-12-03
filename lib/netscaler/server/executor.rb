require 'netscaler/baseexecutor'

module Netscaler::Server
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable(options)
      send_request('enableserver', @params)
    end

    def disable(options)
      send_request('disableserver', @params)
    end

    def list(options)
      send_request('getserver', {:empty => :ok}) do |response|
        puts "[" if options[:json]
        
        servers = response[:return][:list][:item]
        servers.each_with_index do |server, i|
          resp = Response.new(server)
          if options[:json]
            if i == servers.length - 1
              puts "    #{resp.to_json}"
            else
              puts "    #{resp.to_json},"
            end
          else
            puts resp.to_s
            puts
          end
        end

        puts "]"if options[:json]
      end      
    end

    def status(options)
      send_request('getserver', @params) do |response|
        resp = Response.new(response[:return][:list][:item])
        if options[:json]
          puts resp.to_json
        else
          puts resp.to_s
        end
      end
    end
  end

  class Response
    attr_reader :info

    def initialize(raw_response)
      @info = raw_response
    end

    def name
      info[:name]
    end

    def ip_address
      info[:ipaddress]
    end

    def state
      info[:state]
    end

    def services
      if info[:servicename]
        info[:servicename][:item]
      else
        []
      end
    end

    def to_s
      base = "Name:\t#{name}\nIP:\t#{ip_address}\nState:\t#{state}"

      if !services.empty?
        base << "\nServices:\n"
        services.each do |service|
          base << "\t#{service}\n"
        end
        base
      end

      base
    end

    def to_json
      base = "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}'"

      if services.empty?
        base << " }"
      else
        base << ", 'services': ["

        services.each_with_index do |service, i|
          base << "'#{service}'"
          if i != services.length - 1
            base << ", "
          end
        end

        base << "] }"
      end

      base
    end
  end
end
