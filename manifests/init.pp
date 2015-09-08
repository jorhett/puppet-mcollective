# == Class: mcollective
#
# This module manages the MCollective ecosystem
#
# === Parameters:
#
# [*client_user*]
#   The username clients will use to authenticate. Default: client
#
# [*client_password*]
#   The password clients will use to authenticate
#   Required for mcollective::client and mcollective::middleware classes
#
# [*server_user*]
#   The username servers will use to authenticate. Default: server
#
# [*server_password*]
#   The password servers will use to authenticate.
#   Required for mcollective::server and mcollective::middleware classes
#
# [*broker_user*]
#   The username brokers will use to authenticate. Default: admin
#
# [*broker_password*]
#   The password brokers will use to authenticate to each other
#   Required if hosts > 1
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*hosts*]
#   An array of middleware brokers to connect
#
# [*port*]
#   Which port to connect to. Default: 61613
#
# [*connector_ssl*]
#   Use SSL for connection? (ActiveMQ only) Values: false (default), true
#   Should change port to 61614 if this is enabled
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only) Values: anonymous (default), trusted
#
# [*collectives*]
#   An array of collectives to support. Default ['mcollective']
#
# [*security_provider*]
#   Values: psk (default), sshkey, ssl, aes_security
#
# [*psk_key*]
#   Pre-shared key if provider is psk
#
# [*psk_callertype*]
#   Valid to put in the 'caller' field of each request.
#   Values: uid (default), gid, user, group, identity
#
# [*registerinterval*]
#   How often to resend registration information in seconds. Default 600
#
# === Examples
#
# node default {
#   class { 'mcollective':
#     client_password   => 'changeme',
#     server_password   => 'changeme',
#     security_password => 'changeme',
#   }
# }
#
# Hiera
#   mcollective::client_password   : 'changeme',
#   mcollective::server_password   : 'changeme',
#   mcollective::security_password : 'changeme',
#
class mcollective(
  # Puppet v3 will look for values in Hiera before falling back to defaults defined in params class
  # These values tend to be common based on operating system
  $etcdir               =  $mcollective::params::etcdir,
  $libdir               =  $mcollective::params::libdir,
  $logfile              =  $mcollective::params::logfile,
  $stomp_package        =  $mcollective::params::stomp_package,
  $stomp_version        =  'latest',

  # Puppet v3 will look for values in Hiera before falling back to defaults defined here
  $server_user          =  'server',
  $server_password      = undef,
  $client_user          =  'client',
  $client_password      = undef,
  $broker_user          =  'admin',
  $broker_password      = undef,
  $connector            = 'activemq',
  $connector_ssl        = false,
  $connector_ssl_type   = 'anonymous',
  $port                 = undef,
  $hosts,               # array required - no default value
  $collectives          = ['mcollective'],
  $registerinterval     = 600,
  $security_provider    = 'psk',
  $psk_key              = undef,   # will be checked if provider = psk
  $psk_callertype       = 'uid',
)
  inherits mcollective::params {

  # Ensure that someone can order against this main class
  #contain 'mcollective::client'
  #contain 'mcollective::server'
  #contain 'mcollective::facts'
  #contain 'mcollective::middleware'

  # The main module just presets variables used in client classes.
  validate_array( $hosts )
  validate_re( $connector, [ '^activemq$', '^rabbitmq$' ] )
  validate_re( $security_provider, [ '^psk$', '^sshkey$', '^ssl', '^aes_security' ] )
  validate_bool( $connector_ssl )

  if( $security_provider == 'psk' ) {
    validate_re( $psk_key, '^\S{20}', 'Please use a longer string of non-whitespace characters for the pre-shared key' )
  }

  # Set the appropriate default port based on whether SSL is enabled
  if( $port != undef ) {
    $_port = $port
  }
  else {
    $_port = $connector_ssl ? { true => 61614, default => 61613 }
  }

  # Ensure that the common dependency is up to date
  package { $stomp_package:
    ensure => $stomp_version,
  }

  # ensure the ssl directory exists for the lient and server modules
  if( ( $mcollective::security_provider == 'aes_security' ) or ( $mcollective::security_provider == 'ssl' ) ) {
    file { "${etcdir}/ssl":
      ensure => directory,
      owner  => 0,
      group  => 0,
      mode   => '0555',
    }
    if( $mcollective::security_provider == 'ssl' ) {
      file { "${etcdir}/ssl/server":
        ensure => directory,
        owner  => 0,
        group  => 0,
        mode   => '0555',
      }
      @file { "${etcdir}/ssl/server/public.pem":
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0444',
        links   => follow,
        replace => true,
        source  => 'puppet:///modules/mcollective/ssl/server/public.pem',
      }
    }
  }
}
