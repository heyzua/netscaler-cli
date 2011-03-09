require 'netscaler/errors'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'netscaler/extensions'

module Netscaler
  class Executor
    
    def initialize(request_class)
      @request_class = request_class
    end

    def execute!(args, options)
      Netscaler::Logging.configure(options[:debug])

      Netscaler::Transaction.new options[:netscaler] do |client|
        @request_class.new(client).send(options[:action], args[0], options) do |response|
          if options[:json]
            puts response.to_json
          else
            if response.is_a?(Array)
              if response.length > 0
                puts response[0].header
              end
            else
              puts response.header
            end
            puts response.to_s
          end
        end
      end
    end
  end
end
