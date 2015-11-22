# == Type: mcollective::userconfig
#
# This module manages the MCollective client application
#
# === Parameters
#
# [*user*]
#   The user who should own the file to be created.
#   Default: $title
#
# [*group*]
#   The group who should own the file to be created.
#   Default: wheel
#
# [*homedir*]
#   The home directory of the user
#   Defaults to /home/$user
#
# [*filename*]
#   The name of the file to be created, relative to $homedir
#   Defaults to .mcollective
#
# [*hosts*]
#   An array of middleware brokers for the client to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the client to subscribe to
#   Defaults to $mcollective::collectives
#
# [*logger_type*]
#   Where to send log messages. You usually want the user to see them.
#   Values: console (default), syslog, file
#
# [*log_level*]
#   How verbose should logging be?
#   Values: fatal, error, warn (default), info, debug
#
# === Variables
#
# This class makes use of these variables from base mcollective class
#
# [*client_user*]
#   The username clients will use to authenticate.
#   Default: client
#
# [*client_password*]
#   Required: The password clients will use to authenticate
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*port*]
#   Which port to connect to.
#
# [*connector_ssl*]
#   Use SSL service? Values: false, true
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only)
#
# [*security_provider*]
#   Values: psk, sshkey, ssl, aes_security
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
#  mcollective::userconfig { 'jorhett':
#    group  => 'staff',
#  }
#
# Hiera
#   mcollective::userconfigs:
#     jill:
#       group: staff
#     jack: {}
#
define mcollective::userconfig(
  $user         = $title,
  $group        = 'wheel',
  $homedir      = 'unknown',
  $filename     = '.mcollective',

  # This value can be overridden in Hiera or through class parameters
  $etcdir       = $mcollective::etcdir,
  $hosts        = $mcollective::hosts,
  $collectives  = $mcollective::collectives,

  # Logging
  $logger_type  = $mcollective::client::logger_type,
  $log_level    = $mcollective::client::log_level,
) {

  validate_array( $hosts )
  validate_array( $collectives )
  validate_re( $user, '^[._0-9a-zA-Z-]+$' )
  validate_re( $group, '^[._0-9a-zA-Z-]+$' )

  if( $homedir == 'unknown' ) {
    $homepath = "/home/${user}"
  }
  else {
    $homepath = $homedir
  }
  $private_key = "${homepath}/.mcollective.d/private_keys/${user}.pem"
  $public_key  = "${homepath}/.mcollective.d/public_keys/${user}.pem"

  # Stubs for SSL trusted, must be created by user
  $ssl_private = "${homepath}/.puppet/ssl/private_keys/${user}.pem"
  $ssl_cert    = "${homepath}/.puppet/ssl/certs/${user}.pem"
  $ca_cert     = "${homepath}/.puppet/ssl/certs/ca.pem"

  file {[
          "${homepath}/.mcollective.d",
          "${homepath}/.mcollective.d/private_keys",
          "${homepath}/.mcollective.d/public_keys",
          "${homepath}/.mcollective.d/certs",
        ]:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  exec { "create-private-${user}":
    path    => '/usr/bin:/usr/local/bin',
    command => "openssl genrsa -out ${private_key} 2048",
    unless  => "/usr/bin/test -e ${private_key}",
  }

  exec { "create-public-${user}":
    path    => '/usr/bin:/usr/local/bin',
    command => "openssl rsa -in ${private_key} -out ${public_key}",
    unless  => "/usr/bin/test -e ${public_key}",
    require => Exec["create-private-${user}"],
  }

  file { "${homepath}/${filename}":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0440',
    content => template( 'mcollective/userconfig.erb' ),
  }
}
