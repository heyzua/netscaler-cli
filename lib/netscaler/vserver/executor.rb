require 'netscaler/baseexecutor'

module Netscaler::VServer
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable
      send_request('enablelbvserver', @params)
    end

    def disable
      send_request('disablelbvserver', @params)
    end

    def status
      send_request('getlbvserver', @params) do |response|
        puts "Name:       #{response[:return][:list][:item][:name]}"
        puts "IP Address: #{response[:return][:list][:item][:svcipaddress][:item]}"
        puts "Port:       #{response[:return][:list][:item][:svcport][:item]}"
        puts "State:      #{response[:return][:list][:item][:svcstate][:item]}"
      end
    end

    def bind(policy_name)
      params = { 
        :name => host,
        :policyname => policy_name,
        :priority => 1,
        :gotopriorityexpression => 'END' 
      }

      send_request('bindlbvserver_policy', params) do |response|
        require 'pp'
        pp response
      end
    end

    def unbind(policy_name)
      params = {
        :name => host,
        :policyname => policy_name, 
        :type => 'REQUEST'
      }

      send_request('unbindlbvserver_policy', params) do |response|
        require 'pp'
        pp response
      end
    end
  end
end
