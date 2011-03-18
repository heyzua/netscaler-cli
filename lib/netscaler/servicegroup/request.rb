require 'netscaler/base_request'
require 'netscaler/servicegroup/response'

module Netscaler::ServiceGroup
  class Request < Netscaler::BaseRequest
    def enable(service, options)
      params = { :servicegroupname => service }
      send_request('enableservicegroup', params)
    end

    def disable(servicegroup, options)
      params = { 
        :servicegroupname => servicename, 
        :delay => 0 
      }
      send_request('disableservicegroup', params)
    end

    def bind(servicegroup, options)
      params = {
        :name => options[:vserver],
        :servicegroupname => servicegroup
      }
      send_request('bindlbvserver_servicegroup', params)
    end

    def unbind(servicegroup, options)
      params = {
        :name => options[:vserver],
        :servicename => servicegroup
      }
      send_request('unbindlbvserver_servicegroup', params)
    end

    def status(servicegroup, options)
      params = { :servicegroupname => servicegroup }
      send_request('getservicegroup', params) do |response|
        yield Response.new(response).to_hash if block_given?
      end
    end
  end
end

