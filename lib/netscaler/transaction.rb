require 'netscaler/logging'
require 'savon'

module Netscaler
  NSCONFIG_NAMESPACE = "urn:NSConfig"

  class Transaction
    include Logging

    def initialize(config, &block)
      @config = config
      if block_given?
        execute(&block)
      end
    end

    def execute(&block)
      if !block_given?
        raise Netscaler::TransactionError.new("No execution block given.")
      end
      
      log.debug("Beginning the transaction execution: #{@config.host}")
      begin
        client = Savon::Client.new do 
          wsdl.endpoint = url
          wsdl.namespace = Netscaler::NSCONFIG_NAMESPACE
        end
        client.http.auth.ssl.verify_mode = :none

        log.debug("Logging in to the Netscaler host.")
        body = { :username => @config.username, :password => @config.password }

        response = client.request :login do
          #soap.namespace = Netscaler::NSCONFIG_NAMESPACE
          soap.body = body
        end

        auth_cookie = response.http.headers['Set-Cookie']
        client.http.headers['Cookie'] = auth_cookie
        log.debug("Got authorization cookie: #{auth_cookie}")

        log.debug("Yielding client control to the calling context")
        yield client
      rescue SystemExit => e
        raise
      rescue Exception => e
        log.fatal(e)
        log.fatal("Unable to execute transaction.")
        raise Netscaler::TransactionError.new(e)
      ensure
        begin
          log.debug("Logging out of the Netscaler host.")
          client.request :logout
        rescue Exception => e
          log.fatal(e)
          log.fatal("Unable to logout.")
        end
      end

      log.debug("Ending the transaction execution: #{@config.host}")
    end

    private
    def url
      "https://#{@config.host}/soap"
    end
  end
end
