require 'netscaler/logging'

module Netscaler
  class BaseRequest
    include Netscaler::Logging

    attr_reader :client

    def initialize(client)
      @client = client
    end

    protected
    def send_request(name, params, &block)
      if params.nil? || params.empty?
        raise Netscaler::TransactionError.new("The parameters were empty.")
      end

      params.delete(:empty)

      log.debug("Calling: #{name}")

      result = client.request name do
        soap.namespace = Netscaler::NSCONFIG_NAMESPACE
        soap.input = name
        body = Hash.new
        params.each do |k,v|
          body[k.to_s] = v
        end
        soap.body = body
      end

      if log.debug?
        require 'pp'
        PP::pp(result.to_hash, $stderr, 80)
      end
      
      response = result.to_hash["#{name.to_s}_response".to_sym]
      msg = response[:return][:message]
      if msg !~ /^Done$/
        log.error(response[:return][:message])
        exit(1)
      elsif block_given?
        yield response
      else
        log.debug(msg)
      end

      result
    end
  end
end
