require 'rubygems'
require 'yaml'
require 'etc'
require 'highline/import'

module Netscaler

  class ConfigurationReader
    def initialize(file=nil)
      @servers = read_config_file(file)
    end

    def [](host)
      found = @servers[host]
      if found.nil?
        raise Netscaler::ConfigurationError.new("The specified Netscaler host was not found")
      end

      if found['username'].nil?
        raise Netscaler::ConfigurationError.new("No username was specified for the given Netscaler host")
      end

      Configuration.new(host, found['username'], found['password'])
    end

    def load_balancers
      @servers.keys
    end

    private
    def read_config_file(file)
      if file.nil?
        file = File.expand_path(".netscaler-cli.yml", Etc.getpwuid.dir)
      end

      if !File.exists?(file)
        raise Netscaler::ConfigurationError.new("Unable to locate the netscaler-cli configuration file")
      end

      begin
        yaml = File.read(file)
        return YAML::load(yaml)
      rescue Exception => e
        raise Netscaler::ConfigurationError.new("Unable to load the netscaler-cli configuration file")
      end
    end
  end

  class Configuration
    attr_reader :host, :username, :password

    def initialize(host, username, password=nil)
      @host = host
      @username = username
      @password = password

      query_password
    end

    def query_password
      if password.nil?
        @password = ask("Netscaler password for host #{host}: ") {|q| q.echo = false }
      end

      if password.nil? || password.empty?
        raise Netscaler::ConfigurationError.new("Unable to read the Netscaler password.")
      end
    end
  end
end
