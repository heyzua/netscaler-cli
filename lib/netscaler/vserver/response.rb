
module Netscaler::VServer
  class Response
    attr_reader :info

    def initialize(raw_response)
      @info = raw_response[:return][:list][:item]
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

      info[:servicename][:item].each_with_index do |name, i|
        srv = ServerInfo.new
        srv.name = name
        srv.state = info[:svcstate][:item][i]
        srv.port = info[:svcport][:item][i]
        srv.ipaddress = info[:svctype][:item][i]
        
        @parsed_servers << srv
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
