require 'netscaler/errors'
require 'netscaler/server/request'
require 'netscaler/server/response'

module Netscaler::Server
  class Executor
    
    def initialize(host, client)
      @request = Request.new(host, client)
    end

    def method_missing(method, *args, &block)
      response = @request.send(method)
      if response
        # TODO: format
      end
    end
  end
end
