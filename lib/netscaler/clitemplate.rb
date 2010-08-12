require 'optparse'
require 'netscaler/errors'
require 'netscaler/version'
require 'netscaler/logging'
require 'netscaler/transaction'
require 'netscaler/config'

module Netscaler
  class CLITemplate
    attr_reader :options, :args, :host, :cli_type

    def initialize(cli_type, args)
      @cli_type = cli_type
      @args = args
    end

    def execute!
      parse!(@args.dup)
      Netscaler::Logging.configure(options[:debug])
      
      Netscaler::Transaction.new(netscaler_configuration) do |client|
        action = options[:action].keys[0]
        args = options[:action][action]
        executor = create_executor(client)

        if args.nil?
          executor.send(action)
        else
          executor.send(action, args)
        end
      end
    end

    def parse!(args)
      begin
        parse_options(args)
        validate_args(args)
      rescue SystemExit => e
        raise
      rescue Netscaler::ConfigurationError => e
        print_error(e.message)
      rescue OptionParser::ParseError => e
        print_error(e.message)
      rescue Exception => e
        STDERR.puts e.backtrace
        print_error(e.message)
      end
    end

    def parse_options(args)
      @options ||= {}
      if @options.empty?
        @options[:action] = Hash.new
      end
      @parsed_options ||= OptionParser.new do |opts|
        interface_header(opts)
        interface_configuration(opts)
        interface_actions(opts)
        interface_information(opts)
      end.parse!(args)
    end

    def interface_configuration(opts)
      opts.separator "   Configuration: "
      opts.on('-n', '--netscaler NETSCALER_ADDRESS',
              "The IP or hostname of the Netscaler load balancer.",
              "This argument is required.") do |n|
        options[:netscaler] = n
      end
      opts.on('-c', '--config CONFIG',
              "The path to the netscaler-cli configuration file.",
              "By default, it is ~/.netscaler-cli.yml") do |c|
        options[:config] = c
      end
      opts.separator ""
    end

    def interface_information(opts)
      opts.separator "   Informative:"
      opts.on('--debug', 
              "Prints extra debug information") do |d|
        options[:debug] = d
      end
      opts.on('-v', '--version',
              "Show the version information") do |v|
        puts "#{File.basename($0)} version: #{Netscaler::Version.to_s}"
        exit
      end
      opts.on('-h', '--help',
              "Show this help message") do
        puts opts
        exit
      end

      opts.separator ""
    end

    def validate_args(args)
      if args.length == 0
        raise Netscaler::ConfigurationError.new("No hosts specified to act on.")
      elsif args.length != 1
        raise Netscaler::ConfigurationError.new("Only one #{cli_type} can be acted on at a time.")
      end

      @host = args[0]

      if options[:action].empty?
        options[:action][:status] = nil
      elsif options[:action].keys.length != 1
        raise Netscaler::ConfigurationError.new("Multiple actions specified -- only one action is supported at a time.")
      end

      if options[:netscaler].nil?
        raise Netscaler::ConfigurationError.new("No Netscaler IP/Hostname given.")
      end
    end

    def netscaler_configuration
      reader = Netscaler::ConfigurationReader.new(options[:config])
      config = reader[options[:netscaler]]
      if config.nil?
        raise Netscaler::ConfigurationError.new("The Netscaler address '#{options[:netscaler]}' is not defined in the configuration file")
      end

      config
    end

    private
    def print_error(e)
      STDERR.puts "#{File.basename($0)}: #{e}"
      STDERR.puts "Try '#{File.basename($0)} --help' for more information"
      exit 1
    end
  end # CLI
end
