module Netscaler::Server
  class Response
    attr_reader :info

    def initialize(raw_response)
      @info = raw_response
    end

    def name
      info[:name]
    end

    def ip_address
      info[:ipaddress]
    end

    def state
      info[:state]
    end

    def services
      if info[:servicename]
        info[:servicename][:item]
      else
        []
      end
    end
  end
end
