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
      @parsed_services ||= []
      return @parsed_services if !@parsed_services.empty? || @info[:servicename].nil?

      if @info[:servicename][:item].is_a?(String)
        @parsed_services << ServiceInfo.new(@info, nil)
      else
        @info[:servicename][:item].each_with_index do |name, i|
          @parsed_services << ServiceInfo.new(@info, i)
        end
      end

      @parsed_services
    end

    def to_hash
      hash = { 
        :name => name,
        :ip_address => ip_address,
        :state => state,
      }

      if !services.empty?
        hash[:services] = services.map {|s| s.to_hash}
      end

      hash
    end
  end

  class ServiceInfo
    attr_reader :name, :type, :state, :ip_address, :servicegroup

    def initialize(raw_response, index)
      @name = raw_response[:servicename][:item]
      @ip_address = raw_response[:serviceipaddress][:item]
      @state = raw_response[:svrstate][:item]
      @port = raw_response[:port][:item]
      @type = raw_response[:servicetype][:item]

      if !index.nil?
        @name = @name[index]
        @ip_address = @ip_address[index]
        @state = @state[index]
        @port = @port[index]
        @type = @type[index]
      end

      @servicegroup = if raw_response[:servicegroupname] && raw_response[:servicegroupname][:item]
                        ServiceGroupInfo.new(raw_response, index)
                      else
                        nil
                      end
    end

    def port
      @port.to_i
    end

    def to_hash
      hash = {
        :name => name,
        :ip_address => ip_address,
        :type => type,
        :state => state,
        :port => port,
      }

      if servicegroup
        hash[:servicegroup] = servicegroup.to_hash
      end

      hash
    end
  end

  class ServiceGroupInfo
    attr_reader :name, :state

    def initialize(raw_response, index)
      @name = raw_response[:servicegroupname][:item]
      @state = raw_response[:boundservicegroupsvrstate][:item]

      if !index.nil?
        @servicegroup = @servicegroup[index]
        @servicegroup_state = @servicegroup_state[index]
      end
    end

    def to_hash
      { :name => name,
        :state => state
      }
    end
  end
end
