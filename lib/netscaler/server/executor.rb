require 'netscaler/baseexecutor'

module Netscaler::Server
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable
      send_request('enableserver', @params)
    end

    def disable
      send_request('disableserver', @params)
    end

    def status
      send_request('getserver', @params) do |response|
        info = response[:return][:list][:item]
        puts "Name:       #{info[:name]}"
        puts "IP Address: #{info[:ipaddress]}"
        puts "State:      #{info[:state]}"
      end
    end
  end
end
