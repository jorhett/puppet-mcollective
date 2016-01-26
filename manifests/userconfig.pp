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
# [*sshkey_private_key_content*]
#    Defines the content of the private key file for hiera-eyaml integration
#    Default: undefined
#    When undefined, openssl will be invoked to generate a new private key
#    This will not inherit from mcollective::client
#
# === Variables
#
# This class makes use of these variables from base mcollective class and client mcollective class
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
# [*sshkey_publickey_dir*]
#    Defines a directory to store received sshkey-based keys
#    Default: undefined  (only matters if security_provider is sshkey)
#
# [*sshkey_learn_public_keys*]
#    Allows the sshkey plugin to write out sent keys to [*sshkey_publickey_dir*]
#    Default: Do not send  (only matters if security_provider is sshkey)
#    Values: true,false (default)
#
# [*sshkey_overwrite_stored_keys*]
#    In the event of a key mismatch, overwrite stored key data
#    Default: Do not overwrite  (only matters if security_provider is sshkey)
#    Values: true, false (default)
#
# [*sshkey_private_key*]
#    A private key used to sign requests with
#    Default: undefined  (only matters if security_provider is sshkey)
#    When undefined, sshkey uses the ssh-agent to find a key
#
# [*sshkey_known_hosts*]
#    A known_hosts file
#    Default: undefined  (only matters if security_provider is sshkey)
#    When undefined, sshkey uses /home/$USER/.ssh/known_hosts which is the same as OpenSSH by default
#
# [*sshkey_send_key*]
#    Send the specified public key along with the request for dynamic key management
#    Default: undefined  (only matters if security_provider is sshkey)
#
# [*trusted_ssl_server_cert*]
#   The path to your trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/certs/
#
# [*trusted_ssl_server_cert_content*]
#   The content of your trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/certs/
#
# [*trusted_ssl_server_key*]
#   The path to your private key used with the trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/private_keys/
#
# [*trusted_ssl_server_key_content*]
#   The content of your private key used with the trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/private_keys/
#
# [*trusted_ssl_ca_cert*]
#   The path to your trusted certificate authority certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/certs/
#
# [*trusted_ssl_ca_cert_content*]
#   The content of your trusted certificate authority certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure, captured to your home directory at .puppet/ssl/certs/
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
  $etcdir                           = $mcollective::etcdir,
  $hosts                            = $mcollective::hosts,
  $collectives                      = $mcollective::collectives,
  $trusted_ssl_server_cert          = undef,
  $trusted_ssl_server_cert_content  = undef,
  $trusted_ssl_server_key           = undef,
  $trusted_ssl_server_key_content   = undef,
  $trusted_ssl_ca_cert              = undef,
  $trusted_ssl_ca_cert_content      = undef,

  # Logging
  $logger_type  = $mcollective::client::logger_type,
  $log_level    = $mcollective::client::log_level,
  
  # Authentication
  $sshkey_private_key           = $mcollective::client::sshkey_private_key,
  $sshkey_private_key_content   = undef,
  $sshkey_known_hosts           = $mcollective::client::sshkey_known_hosts,
  $sshkey_send_key              = $mcollective::client::sshkey_send_key,
  $sshkey_publickey_dir         = $mcollective::client::sshkey_publickey_dir,
  $sshkey_learn_public_keys     = $mcollective::client::sshkey_learn_public_keys,
  $sshkey_overwrite_stored_keys = $mcollective::client::sshkey_overwrite_stored_keys,
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
  
  $trusted_ssl_server_cert_real = "${homepath}/.puppet/ssl/certs/${user}.pem"
  $trusted_ssl_server_key_real  = "${homepath}/.puppet/ssl/private_keys/${user}.pem"
  $trusted_ssl_ca_cert_real     = "${homepath}/.puppet/ssl/certs/ca.pem"
  
  # Capture the information needed for trusted SSL connections to the local user directory to prevent permission issues
  if( $mcollective::connector_type_ssl == 'trusted') {
    file {["${homepath}/.puppet","${homepath}/.puppet/ssl","${homepath}/.puppet/ssl/certs","${homepath}/.puppet/ssl/private_keys"]:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
    file {$trusted_ssl_server_cert_real:
      ensure  =>  file,
      owner   =>  $user,
      group   =>  $group,
      mode    =>  '0500',
      content  =>  pick($trusted_ssl_server_cert_content,file($trusted_ssl_server_cert),file($mcollective::trusted_ssl_server_cert)),
    }
    file {$trusted_ssl_server_key_real:
      ensure  =>  file,
      owner   =>  $user,
      group   =>  $group,
      mode    =>  '0500',
      content  =>  pick($trusted_ssl_server_key_content,file($trusted_ssl_server_key),file($mcollective::trusted_ssl_server_key)),
    }
    file {$trusted_ssl_ca_cert_real:
      ensure  =>  file,
      owner   =>  $user,
      group   =>  $group,
      mode    =>  '0500',
      content  =>  pick($trusted_ssl_ca_cert_content,file($trusted_ssl_ca_cert),file($mcollective::trusted_ssl_ca_cert)),
    }
  }
  
  # Create the parent default directory if needed
  if( !$sshkey_private_key or !$sshkey_send_key){
    file {"${homepath}/.mcollective.d":
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
  }
  
  # If you specified a sshkey private key, use it otherwise create one
  if( $sshkey_private_key) {
    $private_key = $sshkey_private_key
  }
  else {
    file {"${homepath}/.mcollective.d/private_keys":
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
    
    $private_key = "${homepath}/.mcollective.d/private_keys/${user}.pem"
  }
  
  # If the key content was provided, use it
  if( $sshkey_private_key_content ){
    file {$private_key:
      ensure  =>  file,
      owner   =>  $user,
      group   =>  $group,
      mode    =>  '0500',
      content =>  $sshkey_private_key_content,
    }
  }
  else {
    # Generate a new private key
    exec { "create-private-${user}":
      path    => '/usr/bin:/usr/local/bin',
      command => "openssl genrsa -out ${private_key} 2048",
      unless  => "/usr/bin/test -e ${private_key}",
    }
    
    file {$private_key:
      ensure  =>  file,
      owner   =>  $user,
      group   =>  $group,
      mode    =>  '0500',
      subscribe =>  Exec["create-private-${user}"],
    }
  }
  
  # If you specified a sshkey public key, use it otherwise create one
  if( $sshkey_send_key) {
    $public_key = $sshkey_send_key
  }
  else {
    file {"${homepath}/.mcollective.d/public_keys":
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
    
    $public_key  = "${homepath}/.mcollective.d/public_keys/${user}.pem"
  }
  
  exec { "create-public-${user}":
    path    => '/usr/bin:/usr/local/bin',
    command => "ssh-keygen -y -f ${private_key} > ${public_key}",
    unless  => "/usr/bin/test -e ${public_key}",
    require => Exec["create-private-${user}"],
  }
  file {$public_key:
    ensure  =>  file,
    owner   =>  $user,
    group   =>  $group,
    mode    =>  '0500',
    subscribe =>  Exec["create-public-${user}"],
  }

  file { "${homepath}/${filename}":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0440',
    content => template( 'mcollective/userconfig.erb' ),
  }
}
