module Netscaler::Service
  class Response
    FORMAT = "%-30s %15s %10s %10s"

    def initialize(raw_response)
      @info = raw_response[:return][:list][:item]
    end

    def name
      @info[:name]
    end

    def ip_address
      @info[:ipaddress]
    end

    def state
      @info[:svrstate]
    end

    def port
      @info[:port]
    end

    def header
      line = sprintf FORMAT, 'Name', 'IP Address', 'State', 'Port'
      eqls = '=' * line.length
      line + "\n" + eqls
    end
    
    def to_s
      sprintf FORMAT, name, ip_address, state, port
    end

    def to_json(prefix=nil)
      indent = if prefix
                 '  ' + prefix
               else
                 '  '
               end
      "{\n#{indent}'name': '#{name}',\n#{indent}'ip_address': '#{ip_address}',\n#{indent}'state': '#{state}',\n#{indent}'port': #{port}\n#{prefix}}"
    end
  end
end
