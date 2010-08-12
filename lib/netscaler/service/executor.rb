require 'netscaler/baseexecutor'

module Netscaler::Service
  class Executor < Netscaler::BaseExecutor
    def initialize(host, client)
      super(host, client)
    end

    def enable
      attrs = {
        'name' => host
      }
      send_request('enableservice', attrs)
    end

    def disable
      attrs = { 
        'name' => host, 
        'delay' => 0 
      }
      send_request('disableservice', attrs)
    end

    def status
      attrs = { 'name' => host }
      send_request('getservice', attrs) do |response|
        require 'pp'
        pp response
      end
    end

    def bind(vserver)
      attrs = {
        'name' => vserver,
        'servicename' => host
      }
      send_request('bindlbvserver_service', attrs) do |response|
        require 'pp'
        pp response
      end
    end

    def unbind(vserver)
      attrs = {
        'name' => vserver,
        'servicename' => host
      }
      send_request('unbindlbvserver_service', attrs) do |response|
        require 'pp'
        pp response
      end
    end
  end
end
