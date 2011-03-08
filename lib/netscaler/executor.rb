require 'netscaler/errors'
require 'netscaler/logging'
require 'netscaler/transaction'

module Netscaler
  class Executor
    
    def initialize(request_class)
      @request_class = request_class
    end

    def execute!(args, options)
      begin
        Netscaler::Logging.configure(options[:debug])

        Netscaler::Transaction.new options[:netscaler] do |client|
          response = @request_class.new(client).send(options[:action], args[0], options)
          if response
            if options[:json]
              puts response.to_json
            else
              puts response.to_s
            end
          end
        end
      rescue Netscaler::ConfigurationError => e
        print_error(e.message)
        exit 1
      rescue Exception => e
        STDERR.puts e.backtrace
        print_error(e.message)
        exit 1
      end
    end

    private
    def print_error(e)
      STDERR.puts "#{File.basename($0)}: #{e}"
      STDERR.puts "Try '#{File.basename($0)} help' for more information"
      exit 1
    end
  end
end
