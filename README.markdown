# Netscaler CLI

This is a simple command line interface for accessing a Netscaler load balancer.  It is currently alpha software, so use with caution.

# Installing

The command line tools can be installed with:

    gem install netscaler-cli

# Using

The following commands are currently a part of the system:

  * *netscaler-vserver* -- An interface for enabling, disabling, and binding responder policies to a specific virtual server.
  * *netscaler-service* -- An interface for enabling, disabling, and binding virtual servers to specific service.
  
# Configuration

All of the commands rely upon a configuration file in the YAML format.  By default, it looks for a file in your home directory

    ~/.netscaler-cli.yml

Each load balancer requires an entry in the file in the form:

    netscaler.loadbalancer.somecompany.com
       username: 'some.username'
       password: 'super!duper!secret!'

Multiple entries can be in the file; the password setting is not required.  If it is not given in the file, the tool will ask you for it.
