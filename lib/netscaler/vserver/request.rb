require 'netscaler/logging'
require 'netscaler/base_request'
require 'netscaler/vserver/response'

module Netscaler::VServer
  class Request < Netscaler::BaseRequest
    include Netscaler::Logging

    def enable(vserver, options)
      params = { :name => vserver }
      send_request('enablelbvserver', params)
    end

    def disable(vserver, options)
      params = { :name => vserver }
      send_request('disablelbvserver', params)
    end

    def list(vserver, options)
      vservers = []
      send_request('getlbvserver', {:empty => :ok}) do |response|
        vserver = response[:return][:list][:item]
        vservers.each_with_index do |vserver, i|
          vservers << Response.new(vserver)
        end
      end
      vservers
    end

    def status(vserver, options)
      params = { :name => vserver }
      send_request('getlbvserver', params) do |response|
        return Response.new(response)
      end
    end

    def bind(vserver, options)
      params = { 
        :name => vserver,
        :policyname => options[:policy_name],
        :priority => options[:priority],
        :gotopriorityexpression => 'END' 
      }

      send_request('bindlbvserver_policy', params)
    end

    def unbind(vserver, options)
      params = {
        :name => vserver,
        :policyname => options[:policy_name], 
        :type => 'REQUEST'
      }

      send_request('unbindlbvserver_policy', params)
    end
  end
end
