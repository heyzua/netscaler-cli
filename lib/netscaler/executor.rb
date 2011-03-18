require 'netscaler/errors'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'json'

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
            puts JSON.pretty_generate(response)
          else
            STDERR.puts "Tempoararily disabled stdout. Use --json instead.  Sorry...."
            # puts Hirb::Helpers::Tree.render(response)
          end
        end
      end
    end
  end
end
