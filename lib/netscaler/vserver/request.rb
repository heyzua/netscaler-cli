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
        response[:return][:list][:item].each do |vserver|
          vservers << Response.new(vserver).to_hash
        end
      end
      yield vservers if block_given?
    end

    def status(vserver, options)
      params = { :name => vserver }
      send_request('getlbvserver', params) do |response|
        yield Response.new(response).to_hash if block_given?
      end
    end

    def bind(vserver, options)
      params = { 
        :name => vserver,
        :policyname => options[:policy],
        :priority => options[:Priority],
        :gotopriorityexpression => 'END' 
      }

      method = if options[:netscaler].version == "9.2"
                 'bindlbvserver'
               else
                 'bindlbvserver_policy'
               end
      send_request(method, params)
    end

    def unbind(vserver, options)
      params = {
        :name => vserver,
        :policyname => options[:policy], 
        :type => 'REQUEST'
      }

      method = if options[:netscaler].version == "9.2"
                 'unbindlbvserver'
               else
                 'unbindlbvserver_policy'
               end
      send_request(method, params)
    end
  end
end
