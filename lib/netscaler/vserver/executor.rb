require 'netscaler/logging'

module Netscaler::VServer
  class Executor 
    include Netscaler::Logging

    attr_reader :host
    attr_accessor :client

    def initialize(host)
      @host = host
    end

    def enable
      send_request('enablelbvserver')
    end

    def disable
      send_request('disablelbvserver')
    end

    def status
      send_request('getlbvserver') do |response|
        puts "Name:       #{response[:return][:list][:item][:name]}"
        puts "IP Address: #{response[:return][:list][:item][:svcipaddress][:item]}"
        puts "Port:       #{response[:return][:list][:item][:svcport][:item]}"
        puts "State:      #{response[:return][:list][:item][:svcstate][:item]}"
      end
    end

    def bind(policy_name)
      attrs = { 'policyname' => policy_name,
        'priority' => 1,
        'gotopriorityexpression' => 'END' }

      send_request('bindlbvserver_policy', attrs) do |response|
        require 'pp'
        pp response
      end
    end

    def unbind(policy_name)
      attrs = { 'policyname' => policy_name }

      send_request('unbindlbvserver_policy', attrs) do |response|
        require 'pp'
        pp response
      end
    end

    private
    def send_request(name, body_attrs=nil)
      log.debug("Calling: #{name}")

      result = client.send("#{name}!") do |soap|
        soap.namespace = Netscaler::NSCONFIG_NAMESPACE

        body = Hash.new
        body['name'] = host

        if !body_attrs.nil?
          body_attrs.each do |k,v|
            body[k] = v
          end
        end

        soap.body = body
      end

      log.debug(result)
      
      response = result.to_hash["#{name.to_s}_response".to_sym]
      if block_given?
        yield response
      else
        log.info(response[:return][:message])
      end

      result
    end
  end
end
