require 'netscaler/base_request'
require 'netscaler/server/response'

module Netscaler::Server
  class Request < Netscaler::BaseRequest
    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable
      send_request('enableserver', @params)
      nil
    end

    def disable
      send_request('disableserver', @params)
      nil
    end

    def list
      responses = []
      send_request('getserver', {:empty => :ok}) do |response|
        response_part(response).each_with_index do |server, i|
          responses << Response.new(server)
        end
      end      
      responses
    end

    def status
      send_request('getserver', @params) do |response|
        return [Response.new(response_part(response))]
      end
    end

    private
    def respsonse_part(response)
      response[:return][:list][:item]
    end
  end
end
