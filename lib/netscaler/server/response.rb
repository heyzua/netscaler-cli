module Netscaler::Server
  class Response
    FORMAT = "%-30s %15s %10s"

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

    def header
      line = sprintf FORMAT, 'Name', 'IP Address', 'State'
      eqls = '=' * line.length
      line + "\n" + eqls
    end

    def services
      if info[:servicename]
        res = info[:servicename][:item]
        if !res.is_a?(Array)
          [res]
        else
          res
        end
      else
        []
      end
    end

    def to_s
      base = sprintf FORMAT, name, ip_address, state
      if !services.empty?
        base << "\n"
        services.each do |s|
          base << "| service:  #{s}\n"
        end
      end
      base
    end

    def to_json(prefix=nil)
      indent = if prefix
                 prefix + "  "
               else
                 "  "
               end
      base = "{\n#{indent}'name': '#{name}',\n#{indent}'ip_address': '#{ip_address}',\n#{indent}'state': '#{state}'"
      if !services.empty?
        base << ",\n#{indent}'services':\n#{services.to_json(indent)}"
      end
      base.chomp!
      base << "\n#{prefix}}"
    end
  end
end
