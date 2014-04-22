# == Type: mcollective::userconfig
#
# This module manages the MCollective client application
#
# === Parameters
#
# [*username*]
#   Required: The user who should own the file to be created.
#
# [*group*]
#   Required: The group who should own the file to be created.
#
# [*filename*]
#   The name of the file to be created.
#   Defaults to ~username/.mcollective
#
# [*hosts*]
#   An array of middleware brokers for the client to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the client to subscribe to
#   Defaults to $mcollective::collectives
#
# === Variables
#
# This class makes use of these variables from base mcollective class
#
# [*client_user*]
#   The username clients will use to authenticate. Default: client
#
# [*client_password*]
#   Required: The password clients will use to authenticate
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*port*]
#   Which port to connect to. Default: 61613
#
# [*connector_ssl*]
#   Use SSL service? Values: false (default), true
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only) Values: anonymous (default), trusted
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
# === Examples
#
#  class { 'mcollective::client':
#    hosts       => ['activemq.example.net'],
#    collectives => ['mcollective'],
#  }
#
# Hiera
#   mcollective::hosts :
#     - 'activemq.example.net'
#   mcollective::collectives :
#     - 'mcollective'
#
define mcollective::userconfig(
  # This value can be overridden in Hiera or through class parameters
  $etcdir       = $mcollective::etcdir,
  $hosts        = $mcollective::hosts,
  $collectives  = $mcollective::collectives,
  $package      = $mcollective::params::client_package_name,
  $version      = $mcollective::params::client_package_ensure,

  # Require input
  $username,
  $group,
  $file         = '.mcollective'

  # Logging
  $logger_type  = 'console',
  $log_level    = 'info',
)
  inherits mcollective {

  validate_array( $hosts )
  validate_array( $collectives )
  validate_re( $username, '^[._0-9a-zA-Z-]+$' )
  validate_re( $group, '^[._0-9a-zA-Z-]+$' )

  file { "${etcdir}/client.cfg":
    ensure  => file,
    owner   => root,
    group   => $unix_group,
    mode    => 440,
    content => template( 'mcollective/client.cfg.erb' ),
    require => Package[ $package ],
  }

  # Load in all the appropriate mcollective clients
  $defaults  = { version => 'present' }
  create_resources( mcollective::plugin::client, hiera_hash('mcollective::plugin::clients'), $defaults )                                             
}
