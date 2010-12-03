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

    def status(options)
      send_request('getserver', @params) do |response|
        resp = Response.new(response)
        if options[:json]
          puts resp.to_json
        else
          puts resp.to_s
        end
      end
    end
  end

  class Response
    attr_reader :raw_response, :info

    def initialize(raw_response)
      @raw_response = raw_response
      @info = raw_response[:return][:list][:item]
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
      info[:servicename][:item]
    end

    def to_s
      base = "Name:\t#{name}\nIP Address:\t#{ip_address}\nState:\t#{state}\nServices:\n"
      services.each do |service|
        base << "\t#{service}\n"
      end
      base
    end

    def to_json
      base = "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}', 'services': ["

      services.each_with_index do |service, i|
        base << "'#{service}'"
        if i != services.length - 1
          base << ", "
        end
      end

      base << "] }"
    end
  end
end
