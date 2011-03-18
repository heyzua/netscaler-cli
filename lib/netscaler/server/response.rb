module Netscaler::Server
  class Response
    def initialize(raw_response)
      @info = raw_response
    end

    def name
      @info[:name]
    end

    def ip_address
      @info[:ipaddress]
    end

    def state
      @info[:state]
    end

    def services
      @services ||= if @info[:servicename]
                      res = @info[:servicename][:item]
                      if res.is_a?(Array)
                        res
                      else
                        [res]
                      end
                    else
                      []
                    end
    end

    def to_hash
      hash = { 
        :name => name,
        :ip_address => ip_address,
        :state => state,
      }

      if !services.empty?
        hash[:services] = services
      end

      hash
    end
  end
end
