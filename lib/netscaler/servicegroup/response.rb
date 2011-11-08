module Netscaler::ServiceGroup
  class Response
    def initialize(raw_response)
      @info = raw_response[:return][:list][:item]
    end

    def name
      @info[:servicegroupname]
    end

    def state
      @info[:state]
    end

    def type
      @info[:servicetype]
    end

    def servers
      @parsed_servers ||= []
      return @parsed_servers if !@parsed_servers.empty? || @info[:servername].nil?

      if @info[:servername][:item].is_a?(String)
        @parsed_servers << ServerInfo.new(@info, nil)
      else
        @info[:servername][:item].each_with_index do |name, i|
          @parsed_servers << ServerInfo.new(@info, i)
        end
      end

      @parsed_servers
    end

    def to_hash
      hash = { 
        :name => name,
        :state => state,
        :type => type,
      }

      if !servers.empty?
        hash[:servers] = servers.map {|s| s.to_hash}
      end

      hash
    end
  end

  class ServerInfo
    attr_reader :name, :ip_address, :state

    def initialize(raw_response, index)
      @name = raw_response[:servername][:item]
      @ip_address = raw_response[:ipaddress][:item]
      @state = raw_response[:svcstate][:item]
      @port = raw_response[:port][:item]

      if !index.nil?
        @name = @name[index]
        @ip_address = @ip_address[index]
        @state = @state[index]
        @port = @port[index]
      end
    end

    def port
      @port.to_i
    end

    def to_hash
      { :name => name,
        :ip_address => ip_address,
        :state => state,
        :port => port
      }
    end
  end
end
