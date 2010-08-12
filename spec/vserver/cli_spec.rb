require 'helpers'
require 'netscaler/vserver/cli'

module Netscaler::VServer

  module CLIHelper
    def parse(*args)
      cli = CLI.new(args)
      cli.parse_options(args)
      cli.options
    end
  end

  describe "The CLI interface" do
    include CLIHelper

    it "should set the --netscaler flag correctly." do
      parse('--netscaler', 'localhost')[:netscaler].should eql('localhost')
    end

    it "should set the --debug flag correctly." do
      parse('--debug')[:debug].should be(true)
    end

    it "should set the --enable flag correctly." do
      parse('--enable')[:action].has_key?(:enable).should be(true)
    end

    it "should set the --disable flag correctly." do
      parse('--disable')[:action].has_key?(:disable).should be(true)
    end

    it "should set the --bind flag correctly." do
      parse('--bind', 'some-policy')[:action][:bind].should eql('some-policy')
    end

    it "should set the --unbind flag correctly." do
      parse('--unbind', 'some-policy')[:action][:unbind].should eql('some-policy')
    end

    it "should set the --config flag correctly." do
      parse('--config', 'CONFIG')[:config].should eql('CONFIG')
    end
  end
end
