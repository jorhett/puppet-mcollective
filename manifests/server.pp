# == Class: mcollective::server
#
# This module manages the MCollective server agent
#
# === Parameters
#
# [*etcdir*]
#   Location of mcollective configuration files.
#   Defaults to $mcollective::etcdir which defaults to os-dependent location
#
# [*libdir*]
#   Location of mcollective ruby lib directory.
#   Defaults to an os-dependent location in mcollective::params
#
# [*hosts*]
#   An array of middleware brokers for the server to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the server to subscribe to
#   Defaults to $mcollective::collectives
#
# [*package*]
#   The name of the package to install or remove
#   Defaults to os-dependent value from mcollective::params
#
# [*version*]
#   The version or state of the package
#   Values: latest (default) , present, absent, or specific version number
#
# [*service*]
#   The name of the service to manage
#   Defaults to os-dependent value from mcollective::params
#
# [*ensure*]
#   Should the service be running?
#   Values: running (default), stopped
#
# [*enable*]
#   Should the service start at boot?
#   Values: true (default), false
#
# [*allow_managed_resources*]
#   Allow management of Puppet RAL-style resources?
#   Values: true (default), false
#
# [*resource_type_whitelist*]
#   Which resources are allowed to be managed?
#   Default: none
#
# [*resource_type_blacklist*]
#   If whitelist is empty, which resources should be blocked?
#   Default: null
#
# [*audit_logfile*]
#   If this logfile is specified then auditing is enabled.
#
# [*authorization_enable*]
#   Where or not to enable authorization
#   Values: false (default), true
#
# [*authorization_default_policy*]
#   What authorization policy should be applied to agents with a specific policy?
#
# [*logger_type*]
#   Where to send log messages. You usually want the user to see them.
#   Values: syslog (default), file, console
#
# [*log_level*]
#   How verbose should logging be?
#   Values: fatal, error, warn, info (default), debug
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
# [*logrotate_directory*]
#    Directory where logrotate files are stored.
#    Default: /etc/logrotate.d
#    Nil or Undef value will disable logrotate installation
#
# [*sshkey_authorized_keys*]
#    Defines a authorized keys file for use instead of ~/.ssh/authorized_keys
#    Default: undefined  (only matters if security_provider is sshkey)
#
# === Variables
#
# This class makes use of these variables from base mcollective class
#
# [*server_user*]
#   The username servers will use to authenticate. Default: server
#
# [*server_password*]
#   The password servers will use to authenticate.
#   Required: The password servers will use to authenticate
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*port*]
#   Which port to connect to. Default: 61613
#
# [*connector_ssl*]
#   Use SSL connection to the service? Values: false (default), true
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only)
#   Values: anonymous (default), trusted
#
# [*security_provider*]
#   Values: psk (default), ssl, aes_security, sshkey
#
# [*psk_key*]
#   Pre-shared key if provider is psk
#
# [*registerinterval*]
#   How often to resend registration information in seconds. Default 600
#
# === Examples
#
#  class { 'mcollective::server':
#    authorization_enable => true,
#  }
#
# Hiera
#   mcollective::server::authorization_enable : true,
#
class mcollective::server(
  # Package and Service defaults that are OS-specific, can override in Hiera
  $package                      = $mcollective::params::package_name,
  $service                      = $mcollective::params::service_name,
  $libdir                       = $mcollective::params::libdir,
  $etcdir                       = $mcollective::etcdir,

  # Connector settings
  # These values can be overridden for a given server in Hiera
  $version                      = 'latest',
  $ensure                       = 'running',
  $enable                       = true,
  $hosts                        = $mcollective::hosts,
  $collectives                  = $mcollective::collectives,

  # Authorization
  $allow_managed_resources      = true,
  $resource_type_whitelist      = 'none',
  $resource_type_blacklist      = undef,
  $audit_logfile                = undef,
  $authorization_enable         = undef,
  $authorization_default_policy = undef,
  $ssh_authorized_keys          = undef,

  # Logging
  $logrotate_directory          = $mcollective::params::logrotate_directory,
  $logfile                      = $mcollective::params::logfile,
  $logger_type                  = 'syslog',
  $log_level                    = 'info',
  $logfacility                  = 'user',
  $keeplogs                     = '5',
  $max_log_size                 = '2097152',
)
  inherits mcollective {

  validate_array( $hosts )
  validate_array( $collectives )
  validate_re( $version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$' )
  validate_re( $ensure, '^running$|^stopped$' )
  validate_bool( $enable )

  # Validate that server username and password were supplied
  validate_re( $server_user, '^.{5}', 'Please provide a server username' )
  validate_re( $server_password, '^.{12}', 'Please provide at last twelve characters in server password' )

  # Ensure the facts cronjob is set up or removed
  include mcollective::facts::cronjob

  # Now install the packages
  package { $package:
    ensure => $version,
    notify => Service[ $service ],
  }

  file { "${etcdir}/server.cfg":
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0400',
    content => template( 'mcollective/server.cfg.erb' ),
    require => Package[ $package ],
    notify  => Service[ $service ],
  }

  # Management of SSL keys
  if( ( $mcollective::security_provider == 'aes_security' ) or ( $mcollective::security_provider == 'ssl' ) ) {
    Package[$package] -> File["${etcdir}/ssl"]

    # copy client public keys to all servers
    file { "${etcdir}/ssl/clients":
      ensure  => directory,
      owner   => 0,
      group   => 0,
      mode    => '0755',
      links   => follow,
      purge   => true,
      force   => true,
      recurse => true,
      source  => 'puppet:///modules/mcollective/ssl/clients',
      require => Package[ $package ],
      before  => Service[ $service ],
    }

    # For SSL module One keypair is shared across all servers
    if( $mcollective::security_provider == 'ssl' ) {
      # Get the public key
      realize File["${etcdir}/ssl/server/public.pem"]

      # ...and the private key
      file { "${etcdir}/ssl/server/private.pem":
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0400',
        links   => follow,
        replace => true,
        source  => 'puppet:///modules/mcollective/ssl/server/private.pem',
        require => [ Package[ $package ], File["${etcdir}/ssl/server/public.pem"] ],
        before  => Service[ $service ],
      }
    }
  }

  # Policies used by the authorization plugins
  if( $authorization_enable ) {
    # Copy any files from the policies directory
    file { "${etcdir}/policies":
      ensure  => directory,
      owner   => 0,
      group   => 0,
      mode    => '0444',
      links   => follow,
      recurse => true,
      replace => true,
      force   => true,
      purge   => false,
      source  => 'puppet:///modules/mcollective/policies',
      require => Package[ $package ],
      before  => Service[ $service ],
    }

    file { "${libdir}/mcollective/util":
      ensure  => directory,
      owner   => 0,
      group   => 0,
      mode    => '0755',
      require => Package[ $package ],
      before  => Service[ $service ],
    }

    file { "${libdir}/mcollective/util/actionpolicy.rb":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0444',
      source  => 'puppet:///modules/mcollective/actionpolicy-auth/util/actionpolicy.rb',
      require => File["${etcdir}/server.cfg"],
      before  => Service[ $service ],
    }

    file { "${libdir}/mcollective/util/actionpolicy.ddl":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0444',
      source  => 'puppet:///modules/mcollective/actionpolicy-auth/util/actionpolicy.ddl',
      require => File["${etcdir}/server.cfg"],
      before  => Service[ $service ],
    }

    # Create rules from YAML for the ActionPolicy module
    $actionpolicies  = hiera_hash( 'mcollective::plugin::actionpolicies', false )
    if is_hash( $actionpolicies ) {
      create_resources( mcollective::plugin::actionpolicy, $actionpolicies )
    }
  }

  # Now start the daemon
  service { $service:
    ensure  => $ensure,
    enable  => $enable,
    require => Package[ $package ],
  }

  # Load in all the appropriate mcollective agents
  $defaults  = { version => 'present' }
  $agents  = hiera_hash( 'mcollective::plugin::agents', false )
  if is_hash( $agents ) {
    create_resources( mcollective::plugin::agent, $agents, $defaults )
  }

  # Create or remove a logrotate config for the audit log
  if( $audit_logfile == undef ) {
    $auditlog_ensure = absent
  }
  else {
    $auditlog_ensure = file
  }

  # Only install logrotate if the logrotate directory is installed
  if( $logrotate_directory ) {
    file { 'logrotate-directory':
      ensure => directory,
      path   => $logrotate_directory,
      owner  => 0,
      group  => 0,
      mode   => '0755',
    }
    file { 'logrotate-auditlog':
      ensure  => $auditlog_ensure,
      path    => "${logrotate_directory}/mcollective-auditlog",
      owner   => 0,
      group   => 0,
      mode    => '0444',
      content => template( 'mcollective/logrotate-auditlog.erb' ),
    }
  }
}
