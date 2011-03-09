require 'spec_helpers'
require 'netscaler/config'
require 'netscaler/errors'

module Netscaler

  module ConfigurationHelper
    def reading(file)
      actual_file = File.expand_path("./configs/#{file}", File.dirname(__FILE__))
      Netscaler::ConfigurationReader.read_config_file(actual_file)
    end
  end

  describe "Configuration Reader" do
    include ConfigurationHelper

    before :each do
      @config = reading('simple-config.yml')
    end

    describe "when reading an existing file" do
      it "should be able to load the basic config file" do
        @config.load_balancers.length.should eql(2)
      end

      it "should set the username and password correctly when set in the file." do
        ns = @config['something.goes.here']
        ns.username.should eql('some_user')
        ns.password.should eql('somepass')
      end

      it "should load via an alias" do
        ns = @config['else']
        ns.alias.should eql('else')
        ns.username.should eql('here')
      end

      it "should set the default version to 9.2" do
        ns = @config['something.goes.here']
        ns.version.should eql("9.2")
      end

      it "should read the version if present" do
        ns = @config['else']
        ns.version.should eql("9.1")
      end
    end

    describe "when reading a non-existent or bad file" do
      it "should fail when the config doesn't exist" do
        attempting { reading('non-config.yml') }.should raise_error(Netscaler::ConfigurationError)
      end

      it "should fail when the config is poorly formed" do
        attempting { reading('bad-yaml.yml') }.should raise_error(Netscaler::ConfigurationError)
      end

      it "should fail when the username is missing" do
        attempting { reading('missing-username.yml')['load-balancer'] }.should raise_error(Netscaler::ConfigurationError)
      end
    end
  end
end
