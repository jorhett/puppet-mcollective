# mcollective

## Overview 

<div style="float: right">
    <a href="http://shop.oreilly.com/product/0636920032472.do" target="OReilly"><img src="http://akamaicovers.oreilly.com/images/0636920032472/cat.gif" alt="Cover of Learning MCollective" title="Learning MCollective" align="left" /></a>
</div>

This is an MCollective module for Puppet.  It configures MCollective brokers,
servers, and clients without any other dependency classes, as documented in
[Learning MCollective](http://shop.oreilly.com/product/0636920032472.do).  

O'Reilly Media, Inc.  
http://shop.oreilly.com/product/0636920032472.do  
ISBN: [978-1-4919-4567-4](http://shop.oreilly.com/product/0636920032472.do)  
<br clear="all" />

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
Hiera: common.yaml
    classes: 
      - mcollective::server

    mcollective::hosts:
        - 'activemq.example.net'
    mcollective::client_password: 'Client Password'
    mcollective::server_password: 'Server Password'
    mcollective::psk_key        : 'Salt Value'

Hiera: fqdn/activemq.example.net.yaml
    classes: 
      - mcollective::middleware

Hiera: fqdn/admin.example.net.yaml
    classes: 
      - mcollective::client
```

Or if using in profiles with declarative style assignment:

```puppet
node default {
    include mcollective::server
}
node 'activemq.example.net' {
    include mcollective::middleware
}
node 'admin.example.net' {
    include mcollective::client
}
```

This module is a companion intended for use with the Learning MCollective book.

## Facts

The older version of the book refers to including the `facts` class to have facts
from Facter and Puppet placed in /etc/mcollective/facts.yaml.

```
include mcollective::facts
```

While this still works, it is deprecated and will be removed in a future version.
Instead, add this variable to define how many minutes between updates. 

```YAML
Hiera: common.yaml
    mcollective::facts::cronjob::run_every: 10
```

## Bugs

If you report it, and I can replicate it I'll fix it.

If you have an idea for improvement I might do it. If you create a Pull request
it will happen faster. If you send me changes to support more operating systems,
I'll owe you beer.

I'm human and prone to overwork so response times vary. YMMV.
