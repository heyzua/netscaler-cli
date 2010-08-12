require 'netscaler/logging'

module Netscaler
  class BaseExecutor
    include Netscaler::Logging

    attr_reader :host, :client

    def initialize(host, client)
      @host = host
      @client = client
    end

    protected
    def send_request(name, params)
      if params.nil? || params.empty?
        raise Netscaler::TransactionError.new("The parameters were empty.")
      end

      log.debug("Calling: #{name}")

      result = client.send("#{name}!") do |soap|
        soap.namespace = Netscaler::NSCONFIG_NAMESPACE
        body = Hash.new
        params.each do |k,v|
          body[k.to_s] = v
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
