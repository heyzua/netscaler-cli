require 'spec_helpers'
require 'netscaler/cli'

module Netscaler
  
  module CLIHelper
    def parse(*args)
      args << '-c'
      args << File.join(File.dirname(__FILE__), 'configs', 'simple-config.yml')
      cli = CLI.new(args)
      cli.parse!(true)
    end
  end

  describe CLI do
    include CLIHelper

    it "should fail when the netscaler alias doesn't exist" do
      attempting {
        parse('-n', 'asdf', 'server', '--action', 'list')
      }.should raise_error(Netscaler::ConfigurationError, /host was not found/)
    end

    it "should be able to set the netscaler configuration correctly" do
      res = parse('-n', 'else', 'server', '--action', 'list')
      res.options[:netscaler].password.should eql('blah')
    end

    it "should set the json flag correctly" do
      res = parse('-n', 'else', 'server', '--action', 'list', '--json')
      res.options[:json].should be(true)
    end

    it "should set the debug flag correctly" do
      res = parse('-n', 'else', 'server', '-a', 'list', '--debug')
      res.options[:debug].should be(true)
    end

    describe "for servers" do
      it "should fail when the server is not given to a non-list action" do
        attempting {
          parse('-n', 'else', 'server', '-a', 'status')
        }.should raise_error(Choosy::ValidationError, /no server given/)
      end

      it "should succeed when given the list action with no arguments" do
        res = parse('-n', 'else', 'server', '-a', 'list')
        res.subresults[0][:action].should eql(:list)
      end

      it "should have the server argument on a non-list action" do
        res = parse('-n', 'else', 'server', '-a', 'status', 'blarg')
        res.subresults[0].args[0].should eql('blarg')
        res.subresults[0][:action].should eql(:status)
      end
    end

    describe "for vserver" do
      it "should fail when the vserver is given to a non-list option" do
        attempting {
          parse('-n', 'else', 'vserver', '-a', 'disable')
        }.should raise_error(Choosy::ValidationError, /no virtual server/)
      end

      it "should fail when the --policy flag is unset on a bind/unbind" do
        attempting {
          parse('-n', 'else', 'vserver', '-a', 'bind', 'vserv')
        }.should raise_error(Choosy::ValidationError, /required by the 'bind\/unbind' actions/)
      end

      it "should fail when the --policy flag is used on anything other than bind/unbind" do
        attempting {
          parse('-n', 'else', 'vserver', '-a', 'disable', '-p', 'pol', 'vserv')
        }.should raise_error(Choosy::ValidationError, /only used with bind/)
      end

      it "should fail when priority flag is used on anything other than a bind" do
        attempting {
          parse('-n', 'else', 'vserver', '-a', 'disable', '-P', '20', 'vserv')
        }.should raise_error(Choosy::ValidationError, /only used with the bind action/)
      end

      it "should set the default value for the priority to 100" do
        res = parse('-n', 'else', 'vserver', '-a', 'bind', '-p', 'pol', 'vserv')
        res.subresults[0][:Priority].should eql(100)
      end

      it "should set the policy name" do
        res = parse('-n', 'else', 'vserver', '-a', 'bind', '-p', 'pol', 'vserv')
        res.subresults[0][:policy].should eql('pol')
      end

      it "should fail on a bad action" do
        attempting {
          parse('-n', 'else', 'vserver', '-a', 'asdf', 'vserv')
        }.should raise_error(Choosy::ValidationError, /unrecognized value/)
      end
    end

    describe "for services" do
      it "should fail when the service is given to a non-list action" do
        attempting {
          parse('-n', 'else', 'service', '-a', 'disable')
        }.should raise_error(Choosy::ValidationError, /no services given to act/)
      end
      
      it "should fail when --vserver flag is used with a non-bind/unbind action" do
        attempting {
          parse('-n', 'else', 'service', '-a', 'disable', '-v', 'blarg', 'a-service')
        }.should raise_error(Choosy::ValidationError, /only used with bind/)
      end

      it "should fail when the --vserver flag is not present with the bind/unbind action" do
        attempting {
          parse('-n', 'else', 'service', '-a', 'bind', 'a-service')
        }.should raise_error(Choosy::ValidationError, /requires the -v\/--vserver flag/)
      end

      it "should succeed in setting the service name as an argument" do
        res = parse('-n', 'else', 'service', '-a', 'bind', '-v', 'blah', 'a-service')
        res.subresults[0].args[0].should eql('a-service')
      end

      it "should succed in setting the vserver name" do
        res = parse('-n', 'else', 'service', '-a', 'bind', '-v', 'blah', 'a-service')
        res.subresults[0][:vserver].should eql('blah')
      end

      it "should succeed in setting the action" do
        res = parse('-n', 'else', 'service', '-a', 'bind', '-v', 'blah', 'a-service')
        res.subresults[0][:action].should eql(:bind)
      end

      it "should set the default action to status" do
        res = parse('-n', 'else', 'service', 'a-service')
        res.subresults[0][:action].should eql(:status)
      end
    end

    describe "for servicegroups" do
      it "should fail when the service is given to a non-list action" do
        attempting {
          parse('-n', 'else', 'servicegroup', '-a', 'disable')
        }.should raise_error(Choosy::ValidationError, /no service group given to act/)
      end
      
      it "should fail when --vserver flag is used with a non-bind/unbind action" do
        attempting {
          parse('-n', 'else', 'servicegroup', '-a', 'disable', '-v', 'blarg', 'a-service-group')
        }.should raise_error(Choosy::ValidationError, /only used with bind/)
      end

      it "should fail when the --vserver flag is not present with the bind/unbind action" do
        attempting {
          parse('-n', 'else', 'servicegroup', '-a', 'bind', 'a-service-group')
        }.should raise_error(Choosy::ValidationError, /requires the -v\/--vserver flag/)
      end

      it "should succeed in setting the service name as an argument" do
        res = parse('-n', 'else', 'servicegroup', '-a', 'bind', '-v', 'blah', 'a-service-group')
        res.subresults[0].args[0].should eql('a-service-group')
      end

      it "should succeed in setting the vserver name" do
        res = parse('-n', 'else', 'servicegroup', '-a', 'bind', '-v', 'blah', 'a-service-group')
        res.subresults[0][:vserver].should eql('blah')
      end

      it "should succeed in setting the action" do
        res = parse('-n', 'else', 'servicegroup', '-a', 'bind', '-v', 'blah', 'a-service-group')
        res.subresults[0][:action].should eql(:bind)
      end

      it "should set the default action to status" do
        res = parse('-n', 'else', 'servicegroup', 'a-service-group')
        res.subresults[0][:action].should eql(:status)
      end

      describe "scoping to an individual service" do
        before :each do 
          @res = parse('-n', 'else', 'servicegroup', '-a', 'enable', 'a-service-group', '-s', 'a-server-name', '-p', '8080', '-d', '180')
        end
        
        it "should set the servername to a-server-name" do
          @res.subresults[0][:servername].should eql('a-server-name')
        end
        
        it "should set the port to 8080" do
          @res.subresults[0][:port].should eql('8080')
        end
        
        it "should set the delay to 180" do
          @res.subresults[0][:delay].should eql('180')
        end
        
        it "should set the delay to 0 if not specified" do
          @res = parse('-n', 'else', 'servicegroup', '-a', 'enable', 'a-service-group', '-s', 'a-server-name', '-p', '8080')
          @res.subresults[0][:delay].should eql('0')
        end
      end
    end

  end
end
