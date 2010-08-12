require 'scanf'

module Netscaler
  class Version
    CURRENT = File.read(File.dirname(__FILE__) + '/../VERSION')
    MAJOR, MINOR, TINY = CURRENT.scanf('%d.%d.%d')

    def self.to_s
      CURRENT
    end
  end
end
