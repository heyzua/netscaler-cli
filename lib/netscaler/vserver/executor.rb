require 'netscaler/logging'
require 'netscaler/baseexecutor'

module Netscaler::VServer
  class Executor < Netscaler::BaseExecutor
    include Netscaler::Logging

    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable(options)
      send_request('enablelbvserver', @params)
    end

    def disable(options)
      send_request('disablelbvserver', @params)
    end

    def status(options)
      send_request('getlbvserver', @params) do |response|
        begin
          info = response[:return][:list][:item]
          puts "Name:       #{info[:name]}"
          puts "IP Address: #{info[:svcipaddress][:item]}"
          puts "Port:       #{info[:svcport][:item]}"
          puts "State:      #{info[:svcstate][:item]}"
        rescue Exception => e
          log.fatal "Unable to lookup any information for host: #{host}"
          exit(1)
        end
      end
    end

    def bind(options)
      params = { 
        :name => host,
        :policyname => options[:policy_name],
        :priority => options[:priority],
        :gotopriorityexpression => 'END' 
      }

      send_request('bindlbvserver_policy', params)
    end

    def unbind(options)
      params = {
        :name => host,
        :policyname => options[:policy_name], 
        :type => 'REQUEST'
      }

      send_request('unbindlbvserver_policy', params)
    end
  end
end
