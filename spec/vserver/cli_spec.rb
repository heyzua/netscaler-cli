require 'helpers'
require 'netscaler/vserver/cli'

module Netscaler::VServer

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
      it "should set the --netscaler flag correctly." do
        parse('--netscaler', 'localhost')[:netscaler].should eql('localhost')
      end

      it "should set the --debug flag correctly." do
        parse('--debug')[:debug].should be(true)
      end

      it "should set the --enable flag correctly." do
        parse('--enable')[:action][0].should eql(:enable)
      end

      it "should set the --disable flag correctly." do
        parse('--disable')[:action][0].should eql(:disable)
      end

      it "should set the --bind flag correctly." do
        opts = parse('--bind', 'some-policy')
        opts[:action][0].should eql(:bind)
        opts[:policy_name].should eql('some-policy')
      end

      it "should set the --unbind flag correctly." do
        opts = parse('--unbind', 'some-policy')
        opts[:action][0].should eql(:unbind)
        opts[:policy_name].should eql('some-policy')
      end

      it "should fail when the --priority flag is not an integer" do 
        attempting_to { parse('--priority', 'blah') }.should raise_error(OptionParser::InvalidArgument)
      end

      it "should set the --priority flag correctly." do
        parse('--priority', '6')[:priority].should eql(6)
      end

      it "should set the --config flag correctly." do
        parse('--config', 'CONFIG')[:config].should eql('CONFIG')
      end
    end

    describe "while validating" do
      it "should fail when the priority flag is set with unbind" do
        attempting_to { validate('-n', 'net', '--unbind', 'policy', '--priority', '5', 'host') }.should raise_error(Netscaler::ConfigurationError, /priority/)
      end

      it "should set the priority when the bind flag is set." do
        validate('-n', 'net', '--bind', 'policy', '--priority', '5', 'host') 
      end
    end
  end
end
