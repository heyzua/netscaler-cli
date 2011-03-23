module Netscaler::VServer
  class Response
    def initialize(raw_response)
      @info = if raw_response[:return]
                raw_response[:return][:list][:item]
              else
                raw_response
              end
    end

    def name
      @info[:name]
    end

    def ip_address
      if @info[:ipaddress] =~ /0\.0\.0\.0/
        @info[:ipaddress2]
      else
        @info[:ipaddress]
      end
    end

    def type
      @info[:servicetype]
    end

    def port
      @info[:port].to_i
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

    def service_groups
      @service_groups ||= if @info[:servicegroupname] && @info[:servicegroupname][:item]
                            groups = @info[:servicegroupname][:item]
                            if groups.is_a?(Array)
                              groups
                            else
                              [groups]
                            end
                          else
                            []
                          end
    end

    def to_hash
      hash = { :name => name,
        :ip_address => ip_address,
        :state => state,
        :port => port,
        :type => type,
      }

      if !services.empty?
        hash[:services] = services.map {|s| s.to_hash}
      end

      if !service_groups.empty?
        hash[:service_groups] = service_groups
      end
      
      hash
    end
  end

  class ServiceInfo
    attr_accessor :name, :ip_address, :state, :type

    def initialize(raw_response, index)
      @name = raw_response[:servicename][:item]
      @ip_address = raw_response[:svcipaddress][:item]
      @state = raw_response[:svcstate][:item]
      @port = raw_response[:svcport][:item]
      @type = raw_response[:svctype][:item]

      if !index.nil?
        @name = @name[index]
        @ip_address = @ip_address[index]
        @state = @state[index]
        @port = @port[index]
        @type = @type[index]
      end
    end

    def port
      @port.to_i
    end

    def to_hash
      { :name => name,
        :ip_address => ip_address,
        :state => state,
        :port => port,
        :type => type
      }
    end
  end
end
