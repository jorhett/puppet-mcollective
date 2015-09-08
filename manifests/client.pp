# == Class: mcollective::client
#
# This module manages the MCollective client application
#
# === Parameters
#
# [*etcdir*]
#   Location of mcollective configuration files.
#   Defaults to $mcollective::etcdir which defaults to os-dependent location
#
# [*hosts*]
#   An array of middleware brokers for the client to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the client to subscribe to
#   Defaults to $mcollective::collectives
#
# [*package*]
#   The name of the package to install or remove
#   Defaults to os-dependent value from mcollective::params
#
# [*version*]
#   The version or state of the package
#   Values: latest (default), present, absent, or specific version number
#
# [*unix_group*]
#   The unix group that will be allowed to read the client.cfg file.
#   This is security for the pre-shared-key when PSK is used.
#   Default: wheel
#
# [*logger_type*]
#   Where to send log messages. You usually want the user to see them.
#   Values: console (default), syslog, file
#
# [*log_level*]
#   How verbose should logging be?
#   Values: fatal, error, warn (default), info, debug
#
# [*logfacility*]
#   If logger_type is syslog, which log facility to use? Default: user
#
# [*logfile*]
#   If logger_type is file, what file should the logs be put in?
#   Default is os-dependent, often /var/log/mcollective.log
#
# [*keeplogs*]
#   Any positive value will enable log rotation retaining that many files.
#   A blank or 0 value will disable log rotation.
#   Default: 5
#
# [*max_log_size*]
#    Max size in bytes for log files before rotation happens.
#    Default: 2097152 (2mb)
#
# [*sshkey_known_hosts*]
#    Defines a known hosts file for use instead of ~/.ssh/known_hosts
#    Default: undefined  (only matters if security_provider is sshkey)
#
# [*disc_method*]
#    Defines the default discovery method to use
#    Default: mc
#
# [*disc_options*]
#    Defines the default discovery options to use
#    Default: undefined
#
# [*da_threshold*]
#    Defines the threshold used to determine when to use direct addressing
#    Default: 10
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
class mcollective::client(
  # This value can be overridden in Hiera or through class parameters
  $unix_group   = 'wheel',
  $etcdir       = $mcollective::etcdir,
  $hosts        = $mcollective::hosts,
  $collectives  = $mcollective::collectives,
  $package      = $mcollective::params::client_package_name,

  # Package update?
  $version            = 'latest',
  $sshkey_known_hosts = undef,

  # Logging
  $logfile      = $mcollective::params::logfile,
  $logger_type  = 'console',
  $log_level    = 'warn',
  $logfacility  = 'user',
  $keeplogs     = '5',
  $max_log_size = '2097152',
  $disc_method  = 'mc',
  $disc_options = undef,
  $da_threshold = '10',
)
inherits mcollective {

  validate_array( $hosts )
  validate_array( $collectives )
  validate_re( $version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$' )
  validate_re( $unix_group, '^[._0-9a-zA-Z-]+$' )
  validate_re( $da_threshold, '^[0-9]+$' )

  # Validate that client username and password were supplied
  validate_re( $client_user, '^.{5}', 'Please provide a client username' )
  validate_re( $client_password, '^.{12}', 'Please provide at last twelve characters in client password' )

  package { $package:
    ensure  => $version,
  }

  file { "${etcdir}/client.cfg":
    ensure  => file,
    owner   => root,
    group   => $unix_group,
    mode    => '0440',
    content => template( 'mcollective/client.cfg.erb' ),
    require => Package[ $package ],
  }

  # Handle all per-user configurations
  $userdefaults  = { group => 'wheel' }
  $userlist  = hiera_hash( 'mcollective::userconfigs', false )
  if is_hash( $userlist ) {
    create_resources( mcollective::userconfig, $userlist, $userdefaults )
  }

  # Load in all the appropriate mcollective client plugins
  $defaults  = { version => 'present' }
  $clients  = hiera_hash( 'mcollective::plugin::clients', false )
  if is_hash( $clients ) {
    create_resources( mcollective::plugin::client, $clients, $defaults )
  }

  # Management of SSL keys
  if( $mcollective::security_provider == 'ssl' ) {
    # Ensure the package is installed before we create this directory
    Package[$package] -> File["${etcdir}/ssl"]

    # copy the server public keys to all servers
    realize File["${etcdir}/ssl/server/public.pem"]
  }
}
