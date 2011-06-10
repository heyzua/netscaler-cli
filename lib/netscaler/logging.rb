require 'rubygems'
require 'log4r'
require 'savon'

module Netscaler
  # A convenient module for mixins that allow to
  # share the logging configuration everywhere
  # easily
  module Logging
    @@log = nil

    def Logging.configure(debug)
      if @@log.nil?
        @@log = Log4r::Logger.new 'netscaler'
        @@log.outputters = Log4r::Outputter.stderr
        @@log.level = Log4r::WARN
        Log4r::Outputter.stderr.formatter = Log4r::PatternFormatter.new(:pattern => "[%l]   %M")
        
        @@log.level = debug ? Log4r::DEBUG : Log4r::INFO

        Savon.configure do |config|
          config.log = debug ? true : false
          config.log_level = :debug
          config.logger = @@log
          config.raise_errors = false
        end
      end
    end
    
    def Logging.log
      @@log ||= Log4r::Logger.root
    end
    
    # Meant for mixing into other classes for simplified logging
    def log
      @@log ||= Log4r::Logger.root
    end
  end
end

# SHUT THE HELL UP!
module HTTPI
  class << self
    def log(*messages)
    end
  end
end
