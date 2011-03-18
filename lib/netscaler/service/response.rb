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
      @info[:port].to_i
    end

    def server
      @info[:servername]
    end

    def to_hash
      { :name => name,
        :server => server,
        :ip_address => ip_address,
        :state => state,
        :port => port
      }
    end
  end
end
