require 'netscaler/baseexecutor'

module Netscaler::Service
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable
      send_request('enableservice', @params)
    end

    def disable
      params = { 
        :name => host, 
        :delay => 0 
      }
      send_request('disableservice', params)
    end

    def status
      send_request('getservice', @params) do |response|
        info = response[:return][:list][:item]
        puts "Name:       #{info[:name]}"
        puts "IP Address: #{info[:ipaddress]}"
        puts "Port:       #{info[:port]}"
        puts "State:      #{info[:svrstate]}"
      end
    end

    def bind(vserver)
      params = {
        :name => vserver,
        :servicename => host
      }
      send_request('bindlbvserver_service', params) do |response|
        require 'pp'
        pp response
      end
    end

    def unbind(vserver)
      params = {
        :name => vserver,
        :servicename => host
      }
      send_request('unbindlbvserver_service', params) do |response|
        require 'pp'
        pp response
      end
    end
  end
end
