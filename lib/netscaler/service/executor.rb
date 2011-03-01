require 'netscaler/base_request'

module Netscaler::Service
  class Executor < Netscaler::BaseRequest
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable(options)
      send_request('enableservice', @params)
    end

    def disable(options)
      params = { 
        :name => host, 
        :delay => 0 
      }
      send_request('disableservice', params)
    end

    def bind(options)
      params = {
        :name => options[:vserver],
        :servicename => host
      }
      send_request('bindlbvserver_service', params)
    end

    def unbind(options)
      params = {
        :name => options[:vserver],
        :servicename => host
      }
      send_request('unbindlbvserver_service', params)
    end

    def status(options)
      send_request('getservice', @params) do |response|
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
      info[:svrstate]
    end

    def port
      info[:port]
    end
    
    def to_s
      "Name:\t#{name}\nIP:\t#{ip_address}\nState:\t#{state}\nPort:\t#{port}"
    end

    def to_json
      "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}', 'port': #{port} }"
    end
  end
end
