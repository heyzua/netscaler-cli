require 'netscaler/baseexecutor'

module Netscaler::Service
  class Executor < Netscaler::BaseExecutor
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

    def status(options)
      send_request('getservice', @params) do |response|
        info = response[:return][:list][:item]
        puts "Name:       #{info[:name]}"
        puts "IP Address: #{info[:ipaddress]}"
        puts "Port:       #{info[:port]}"
        puts "State:      #{info[:svrstate]}"
      end
    end

    def bind(options)
      params = {
        :name => options[:vserver],
        :servicename => host
      }
      send_request('bindlbvserver_service', params) do |response|
        #require 'pp'
        #pp response
      end
    end

    def unbind(options)
      params = {
        :name => options[:vserver],
        :servicename => host
      }
      send_request('unbindlbvserver_service', params) do |response|
        #require 'pp'
        #pp response
      end
    end
  end
end
