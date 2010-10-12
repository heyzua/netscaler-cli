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

      client = Savon::Client.new(url) #"file://{File.expand_path('./etc/NSConfig.wsdl', File.dirname(__FILE__))}")
      client.request.http.ssl_client_auth(:verify_mode => OpenSSL::SSL::VERIFY_NONE)

      begin
        log.debug("Logging in to the Netscaler host.")

        response = client.login! do |soap|
          soap.namespace = Netscaler::NSCONFIG_NAMESPACE
          
          body = Hash.new
          body['username'] = @config.username
          body['password'] = @config.password

          soap.body = body
        end
        auth_cookie = response.http['Set-Cookie']
        client.request.headers['Cookie'] = auth_cookie
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
          client.logout! do |soap|
            soap.namespace = Netscaler::NSCONFIG_NAMESPACE
          end
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
