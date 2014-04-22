# mcollective

## Overview 

This is an mcollective module for Puppet.

This module was used in the development of the book
[![Learning MCollective cover](http://akamaicovers.oreilly.com/images/0636920032472/rc_cat.gif)](http://shop.oreilly.com/product/0636920032472.do) 
>  O'Reilly Media, Inc  
>  ISBN: [978-1-4919-4567-4](http://shop.oreilly.com/product/0636920032472.do) 

## Description

This module can configure MCollective middleware brokers,
servers, and clients. It can automatically configure complex configurations,
such as networks of brokers, subcollectives, and TLS security options.

With just a hostname and passwords it can create a fully working 
MCollective setup.  With just a few more lines of input it can create 
TLS-validated, globally distributed MCollective environments.

The module can also create authorization policies from Hiera input.

## Supported Operating Systems

The module has been validated for full functionality on:

* CentOS 6.4 and higher
* Ubuntu 13.10
* FreeBSD 9.2 and higher

Updates for Solaris, MacOS, and Windows coming soon.

## Simple Setup

The easiest setup is to put the passwords in Hiera and then simply
include the modules in site or nodes manifest.

```YAML
Hiera:
    mcollective::hosts:
        - 'activemq.example.net'
    mcollective::client_password: 'Client Password'
    mcollective::server_password: 'Server Password'
    mcollective::psk_key        : 'Salt Value'
```

```puppet
node default.example.net {
    include mcollective::server
}
node activemq.example.net {
    include mcollective::middleware
}
node bastion.example.net {
    include mcollective::client
}
```

This doc needs some love, I hope to get back to it soon.

## Bugs

If you report it, and I can replicate it I'll fix it.

If you have an idea for improvement I might do it. If you create a Pull request
it will happen faster. If you send me changes to support more operating systems,
I'll owe you beer.

I'm human and prone to overwork so response times vary. YMMV.
