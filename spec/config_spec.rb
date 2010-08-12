require 'helpers'
require 'netscaler/config'
require 'netscaler/errors'

module Netscaler

  module ConfigurationHelper
    def reading(file)
      actual_file = File.expand_path("./configs/#{file}", File.dirname(__FILE__))
      Netscaler::ConfigurationReader.new(actual_file)
    end
  end

  describe "Configuration Reader" do
    include ConfigurationHelper

    describe "when reading an existing file" do
      it "should be able to load the basic config file" do
        reading('simple-config.yml').load_balancers.length.should eql(1)
      end

      it "should set the username and password correctly when set in the file." do
        config = reading('simple-config.yml')['something.goes.here']
        config.username.should eql('some_user')
        config.password.should eql('somepass')
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
