require 'scanf'

module Netscaler
  class Version
    CURRENT = File.read(File.join(File.dirname(__FILE__), '..', '..', 'etc', 'Version'))
    MAJOR, MINOR, TINY = CURRENT.scanf('%d.%d.%d')

    def self.to_s
      CURRENT
    end
  end
end
