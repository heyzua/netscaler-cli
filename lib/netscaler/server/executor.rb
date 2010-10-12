require 'netscaler/baseexecutor'

module Netscaler::Server
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable(options)
      send_request('enableserver', @params)
    end

    def disable(options)
      send_request('disableserver', @params)
    end

    def status(options)
      send_request('getserver', @params) do |response|
        info = response[:return][:list][:item]
        puts "Name:       #{info[:name]}"
        puts "IP Address: #{info[:ipaddress]}"
        puts "State:      #{info[:state]}"
      end
    end
  end
end
