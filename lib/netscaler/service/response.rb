module Netscaler::Service
  class Response
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
    
    def to_s
      "Name:\t#{name}\nIP:\t#{ip_address}\nState:\t#{state}\nPort:\t#{port}"
    end

    def to_json
      "{ 'name': '#{name}', 'ip_address': '#{ip_address}', 'state': '#{state}', 'port': #{port} }"
    end
  end
end
