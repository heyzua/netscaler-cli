require 'netscaler/base_request'
require 'netscaler/server/response'

module Netscaler::Server
  class Request < Netscaler::BaseRequest
    def enable(server, options)
      send_request('enableserver', {:name => server})
    end

    def disable(server, options)
      send_request('disableserver', {:name => server})
    end

    def list(server, options)
      responses = []
      send_request('getserver', {:empty => :ok}) do |response|
        response_part(response).each_with_index do |server, i|
          responses << Response.new(server)
        end
      end      
      yield responses if block_given?
    end

    def status(server, options)
      send_request('getserver', {:name => server }) do |response|
        yield Response.new(response_part(response)) if block_given?
      end
    end

    private
    def response_part(response)
      response[:return][:list][:item]
    end
  end
end
