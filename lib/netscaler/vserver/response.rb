
module Netscaler::VServer
  class Response
    FORMAT = "%-47s %15s %15s %10s %10s"

    attr_reader :info

    def initialize(raw_response)
      @info = if raw_response[:return]
                raw_response[:return][:list][:item]
              else
                raw_response
              end
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

    def header
      line = sprintf FORMAT, 'Name', 'IP Address', 'State', 'Port', 'Type'
      eqls = '=' * line.length
      line + "\n" + eqls
    end

    def servers
      @parsed_servers ||= []
      if !@parsed_servers.empty? || info[:servicename].nil?
        return @parsed_servers
      end

      if info[:servicename][:item].is_a?(String)
        @parsed_servers << ServerInfo.new(info, nil)
      else
        info[:servicename][:item].each_with_index do |name, i|
          @parsed_servers << ServerInfo.new(info, i)
        end
      end

      @parsed_servers
    end

    def to_s
      base = sprintf FORMAT, name, ip_address, state, port, type

      if !servers.empty?
        base << "\n"
        servers.each do |server|
          base << "|> server: #{server}\n"
        end
      end

      base
    end

    def to_json(prefix=nil)
      indent = if prefix
                 '  ' + prefix
               else
                 '  '
               end
      base = "{\n#{indent}'name': '#{name}',\n#{indent}'ip_address': '#{ip_address}',\n#{indent}'state': '#{state}',\n#{indent}'port': #{port},\n#{indent}'type': '#{type}'"

      if !servers.empty?
        base << ",\n#{indent}'servers':\n#{servers.to_json(indent)}"
      end

      base << "\n#{prefix}}"
      base
    end
  end

  class ServerInfo
    attr_accessor :name, :ip_address, :state, :port, :type

    def initialize(raw_response, index)
      @name = raw_response[:servicename][:item]
      @ip_address = raw_response[:svcipaddress][:item]
      @state = raw_response[:svcstate][:item]
      @port = raw_response[:svcport][:item]
      @type = raw_response[:svctype][:item]

      if !index.nil?
        @name = @name[i]
        @ip_address = @ip_address[i]
        @state = @state[i]
        @port = @port[i]
        @type = @type[i]
      end
    end

    def to_s
      sprintf "%-26s  %15s %18s %10s %10s", name, ip_address, state, port, type
    end

    def to_json(prefix=nil)
      indent = if prefix
                 '  ' + prefix
               else
                 '  '
               end
      "{\n#{indent}'name': '#{'here' + name}',\n#{indent}'ip_address': '#{ip_address}',\n#{indent}'state': '#{state}',\n#{indent}'port': #{port},\n#{indent}'type': '#{type}'\n#{prefix}}"
    end
  end
end
