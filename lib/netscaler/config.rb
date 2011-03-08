require 'rubygems'
require 'yaml'
require 'etc'
require 'highline/import'

module Netscaler

  class ConfigurationReader
    def initialize(yaml)
      @servers = yaml
    end

    def [](name)
      # First, try the aliases
      @servers.each_key do |lbname|
        found = @servers[lbname]
        if found['alias'] == name
          return create_config(lbname, found)
        end
      end

      # Next, check the actual server names
      found = @servers[name]
      if found.nil?
        raise Netscaler::ConfigurationError.new("The specified Netscaler host was not found")
      end

      return create_config(name, found)
    end

    def load_balancers
      @servers.keys
    end

    def self.read_config_file(file)
      if file.nil?
        file = File.expand_path(".netscaler-cli.yml", Etc.getpwuid.dir)
      end

      if !File.exists?(file)
        raise Netscaler::ConfigurationError.new("Unable to locate the netscaler-cli configuration file")
      end

      begin
        yaml = File.read(file)
        ConfigurationReader.new(YAML::load(yaml))
      rescue Exception => e
        raise Netscaler::ConfigurationError.new("Unable to load the netscaler-cli configuration file")
      end
    end

    private
    def create_config(lbname, yaml)
      if yaml['username'].nil?
        raise Netscaler::ConfigurationError.new("No username was specified for the given Netscaler host")
      end

      Configuration.new(lbname, yaml['username'], yaml['password'], yaml['alias'], yaml['version'])
    end
  end

  class Configuration
    attr_reader :host, :username, :password, :alias, :version

    def initialize(host, username, password=nil, nalias=nil, version=nil)
      @host = host
      @username = username
      @password = password
      @alias = nalias
      @version = if version
                   version.to_s
                 else
                   "9.2"
                 end

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
