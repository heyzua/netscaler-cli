require 'netscaler/base_request'
require 'netscaler/service/response'

module Netscaler::Service
  class Request < Netscaler::BaseRequest
    def enable(service, options)
      params = { :name => service }
      send_request('enableservice', params)
    end

    def disable(service, options)
      params = { 
        :name => service, 
        :delay => 0 
      }
      send_request('disableservice', params)
    end

    def bind(service, options)
      params = {
        :name => options[:vserver],
        :servicename => service
      }
      send_request('bindlbvserver_service', params)
    end

    def unbind(service, options)
      params = {
        :name => options[:vserver],
        :servicename => service
      }
      send_request('unbindlbvserver_service', params)
    end

    def status(service, options)
      params = { :name => service }
      send_request('getservice', params) do |response|
        yield Response.new(response) if block_given?
      end
    end
  end
end
