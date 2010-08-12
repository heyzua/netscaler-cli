require 'netscaler/baseexecutor'

module Netscaler::VServer
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
    end

    def enable
      attrs = { 'name' => host }
      send_request('enablelbvserver', attrs)
    end

    def disable
      attrs = { 'name' => host }
      send_request('disablelbvserver', attrs)
    end

    def status
      attrs = { 'name' => host }
      send_request('getlbvserver', attrs) do |response|
        puts "Name:       #{response[:return][:list][:item][:name]}"
        puts "IP Address: #{response[:return][:list][:item][:svcipaddress][:item]}"
        puts "Port:       #{response[:return][:list][:item][:svcport][:item]}"
        puts "State:      #{response[:return][:list][:item][:svcstate][:item]}"
      end
    end

    def bind(policy_name)
      attrs = { 
        'name' => host,
        'policyname' => policy_name,
        'priority' => 1,
        'gotopriorityexpression' => 'END' 
      }

      send_request('bindlbvserver_policy', attrs) do |response|
        require 'pp'
        pp response
      end
    end

    def unbind(policy_name)
      attrs = {
        'name' => host,
        'policyname' => policy_name, 
        'type' => 'REQUEST'
      }

      send_request('unbindlbvserver_policy', attrs) do |response|
        require 'pp'
        pp response
      end
    end
  end
end
