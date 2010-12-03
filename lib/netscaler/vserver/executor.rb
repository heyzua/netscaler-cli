require 'netscaler/logging'
require 'netscaler/baseexecutor'

module Netscaler::VServer
  class Executor < Netscaler::BaseExecutor
    include Netscaler::Logging

    def initialize(host, client)
      super(host, client)
      @params = { :name => host }
    end

    def enable(options)
      send_request('enablelbvserver', @params)
    end

    def disable(options)
      send_request('disablelbvserver', @params)
    end

    def list(options)
      send_request('getlbvserver', {:empty => :ok}) do |response|
        puts "[" if options[:json]
        
        vservers = response[:return][:list][:item]
        vservers.each_with_index do |vserver, i|
          resp = Response.new(vserver)
          if options[:json]
            if i == vservers.length - 1
              puts "    #{resp.to_json}"
            else
              puts "    #{resp.to_json},"
            end
          else
            puts resp.to_s
            puts
          end
        end

        puts "]"if options[:json]
      end      
    end

    def status(options)
      send_request('getlbvserver', @params) do |response|
        begin
          resp = Response.new(response[:return][:list][:item])
          if options[:json]
            puts resp.to_json
          else
            puts resp.to_s
          end
        rescue Exception => e
          log.fatal "Unable to lookup any information for host: #{host}"
          puts e
          exit(1)
        end
      end
    end

    def bind(options)
      params = { 
        :name => host,
        :policyname => options[:policy_name],
        :priority => options[:priority],
        :gotopriorityexpression => 'END' 
      }

      send_request('bindlbvserver_policy', params)
    end

    def unbind(options)
      params = {
        :name => host,
        :policyname => options[:policy_name], 
        :type => 'REQUEST'
      }

      send_request('unbindlbvserver_policy', params)
    end
  end

  class Response
    attr_reader :info

    def initialize(raw_response)
      @info = raw_response
    end

    def name
      info[:name]
    end

    def ip_address
      if info[:ipaddress] =~ /0\.0\.0\.0/
        info[:ipaddress2]
      else
        info[:ipaddress]
      end
    end

    def type
      info[:servicetype]
    end

    def port
      info[:port]
    end

    def state
      info[:state]
    end

    def servers
      @parsed_servers ||= []
      if !@parsed_servers.empty? || info[:servicename].nil?
        return @parsed_servers
      end

      info[:servicename][:item].each do |name|
        srv = ServerInfo.new
        srv.name = name
        @parsed_servers << srv
      end

      info[:svcstate][:item].each_with_index do |state, i|
        @parsed_servers[i].state = state
      end

      info[:svcport][:item].each_with_index do |port, i|
        @parsed_servers[i].port = port
      end

      info[:svcipaddress][:item].each_with_index do |ip_address, i|
        @parsed_servers[i].ip_address = ip_address
      end

      info[:svctype][:item].each_with_index do |type, i|
        @parsed_servers[i].type = type
      end

      @parsed_servers
    end

    def to_s
      base = "Name:\t#{name}\nIP:\t#{ip_address}\nState:\t#{state}\nPort:\t#{port}\nType:\t#{type}"

      if !servers.empty?
        base << "\nServers:\n"
        servers.each do |server|
          base << server.to_s
          base << "\n\n"
        end
      end

      base
    end

    def to_json
      base = "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}', 'port': #{port}, 'type': '#{type}'"

      if servers.empty?
        base << " }"
      else
        base << ", 'servers': [\n    "

        servers.each_with_index do |server, i|
          base << server.to_json
          if i != servers.length - 1
            base << ",\n    "
          else
            base << "\n"
          end
        end

        base << "] }"
      end

      base
    end
  end

  class ServerInfo
    attr_accessor :name, :ip_address, :state, :port, :type

    def to_s
 "\tName:\t#{name}\n\tIP:\t#{ip_address}\n\tState:\t#{state}\n\tPort:\t#{port}\n\tType:\t#{type}"
    end

    def to_json
      "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}', 'port': #{port}, 'type': '#{type}' }"
    end
  end
end
