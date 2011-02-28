require 'helpers'
require 'netscaler/server/cli'

module Netscaler::Server

  module CLIHelper
    def parse(*args)
      cli = CLI.new(args)
      cli.parse_options(args)
      cli.options
    end

    def validate(*args)
      cli = CLI.new(args)
      cli.parse_options(args)
      cli.validate_args(args)
    end
  end

  describe "The CLI interface" do
    include CLIHelper

    describe "while parsing" do
      it "should set the --enable flag correctly." do
        parse('--enable')[:action][0].should eql(:enable)
      end

      it "should set the --disable flag correctly." do
        parse('--disable')[:action][0].should eql(:disable)
      end
    end
  end
end
