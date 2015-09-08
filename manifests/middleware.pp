# == Class: mcollective::middleware
#
# This module manages the MCollective middleware transport
#
# === Parameters
#
# [*directory*]
#   Location of activemq/rabbitmq configuration files
#   Defaults to $mcollective::params::activemq_directory which defaults to os-dependent location
#
# [*user*]
#   Owner of the middleware configuration files
#   Defaults to $mcollective::params::activemq_user_name which defaults to os-dependent value
#
# [*config_file*]
#   The middleware configuration file
#   Defaults to $mcollective::params::activemq_config_file which defaults to os-dependent value
#
# [*defaults_file*]
#   The middleware init defaults file
#   Defaults to $mcollective::params::activemq_defaults_file which defaults to os-dependent value
#
# [*package*]
#   The name of the package to install or remove
#   Defaults to os-dependent value from mcollective::params::activemq_package_name
#
# [*version*]
#   The version or state of the package: latest, present (default), absent, or specific version number
#
# [*max_connections*]
#   The maximum number of connections: default 1000
#
# [*service*]
#   The name of the service to manage
#   Defaults to os-dependent value from mcollective::params::activemq_service_name
#
# [*java_memory_size*]
#   The memory size allowed for JVM heap
#   Defaults to '512m'
#
# [*ensure*]
#   Should the service be running?
#   Values: running (default), stopped
#
# [*enable*]
#   Should the service start at boot?
#   Values: true (default), false
#
# [*truststore_password*]
#   Password for the TLS Truststore
#
# [*keystore_password*]
#   Password for the TLS Keystore
#
# [*jetty_password*]
#   admin password for (and enable) the ActiveMQ Jetty Web Admin
#   Default: null (disabled)
#
# [*use_jmx*]
#   Whether to enable the ActiveMQ JMX MBeans console
#   Values: true, false (default)
#
# === Variables
#
# This class makes use of these variables from base mcollective class
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*hosts*]
#   An array of middleware brokers for the client to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the client to subscribe to
#   Defaults to $mcollective::collectives
#
# [*client_user*]
#   The username clients will use to authenticate. Default: client
#
# [*client_password*]
#   Required: The password clients will use to authenticate
#
# [*server_user*]
#   The username servers will use to authenticate. Default: server
#
# [*server_password*]
#   The password servers will use to authenticate.
#   Required: The password servers will use to authenticate
#
# [*broker_user*]
#   The username brokers will use to authenticate. Default: admin
#
# [*broker_password*]
#   The password brokers will use to authenticate to each other
#   Required if hosts > 1
#
# [*port*]
#   Which port to connect to. Default: 61613
#
# [*connector_ssl*]
#   Use SSL service? Values: false (default), true
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only)
#   Values: anonymous (default), trusted
#
# [*registerinterval*]
#   How often to resend registration information in seconds. Default 600
#
# === Examples
#
#  class { 'mcollective::middleware':
#    hosts => ['activemq.1.example.net','activemq.2.example.net'],
#  }
#
# Hiera
#   mcollective::middleware::hosts :
#       - activemq.1.example.net
#       - activemq.2.example.net
#
class mcollective::middleware(
  $version          = 'present',
  $max_connections  = '1000',
  $ensure           = 'running',
  $enable           = true,
  $use_jmx          = false,
  $jetty_password   = undef,
  $java_memory_size = '512m',

  # This allows override for just this class
  $hosts         = $mcollective::hosts,

  # These are OS-specific
  $package       = $mcollective::params::activemq_package_name,
  $service       = $mcollective::params::activemq_service_name,
  $user          = $mcollective::params::activemq_user_name,
  $directory     = $mcollective::params::activemq_directory,
  $config_file   = $mcollective::params::activemq_config_file,
  $defaults_file = $mcollective::params::activemq_defaults_file,

  # Truststore and Keystore passwords
  $keystore_password    = undef,    # will be checked if security_provider is either tls option
  $truststore_password  = undef,    # will be checked if security_provider is 'trusted'
)
  inherits mcollective {

  # Make an array of hosts not including self
  validate_absolute_path( $directory )
  validate_array( $hosts )
  if( size($hosts) > 1 ) {
    $remotehostsF = reject($hosts, $::fqdn)
    $remotehostsH = reject($remotehostsF, $::hostname)
    $remotehosts = reject($remotehostsH, $::clientcert)
    if( size($remotehosts) > 0 ) {
      $brokernetwork = true
      validate_string( $mcollective::broker_user )
      validate_string( $mcollective::broker_password )
      if( $mcollective::broker_password == undef ) {
        validate_re( $mcollective::broker_password, '^\S{6,}+', 'Broker password must be at least 6 characters when multiple brokers are listed.' )
      }
    }
  }
  else {
    $remotehosts = []
  }

  # The main module just presets variables used in client classes.
  validate_re( $mcollective::connector, [ '^activemq$', '^rabbitmq$' ] )
  validate_bool( $mcollective::connector_ssl )
  validate_bool( $use_jmx )

  # Validate that client and server username and password were supplied
  validate_re( $client_user, '^.{5}', 'Please provide a client username' )
  validate_re( $client_password, '^.{12}', 'Please provide at last twelve characters in client password' )
  validate_re( $server_user, '^.{5}', 'Please provide a server username' )
  validate_re( $server_password, '^.{12}', 'Please provide at last twelve characters in server password' )


  # Main menu
  package { $package:
    ensure => $version,
    notify => Service[ $service ],
  }

  # If Jetty is enabled, store the password in the jetty realm properties file
  if( ( $mcollective::connector == 'activemq' ) and ( $jetty_password != '' ) and ( $jetty_password != undef ) ) {
    $use_jetty = true

    file { "${directory}/jetty-realm.properties":
      ensure  => file,
      owner   => $user,
      group   => 'nobody',
      mode    => '0440',
      content => template('mcollective/jetty-realm.properties.erb'),
      require => Package[ $package ],
      before  => File["${directory}/${config_file}"],
    }
  }

  # Now build the main file
  file { "${directory}/${config_file}":
    ensure  => file,
    owner   => $user,
    group   => 0,
    mode    => '0400',
    require => Package[ $package ],
    content => template( "mcollective/${config_file}.erb" ),
    notify  => Service[ $service ],
  }

  if( ( $mcollective::connector == 'activemq' ) and ( $defaults_file != '' ) ) {
    file { '/etc/sysconfig/activemq':
      ensure  => file,
      owner   => $user,
      group   => 0,
      mode    => '0444',
      require => Package[ $package ],
      content => template( 'mcollective/activemq.sysconfig.erb' ),
      notify  => Service[ $service ],
    }
  }

  service { $service:
    ensure  => $ensure,
    enable  => $enable,
    require => Package[ $package ],
  }

  # Set up keystore and truststore if necessary
  if( $mcollective::connector_ssl == true ) {
    validate_re( $keystore_password, '^\S{6,}$', 'Keystore password must be at least 6 characters' )
    file { "${directory}/ssl":
        ensure  => directory,
        owner   => $user,
        group   => 0,
        mode    => '0500',
        require => Package[ $package ],
    }
    # Keystore
    Exec {
      path    => ['/bin:/usr/bin:/usr/local/bin'],
      timeout => 20,
    }
    # I don't like it, but there's no easy way to build a template of local files.
    # These operations are protected by the directory being unreadable except by activemq user and root
    exec { 'mcollective-create-pem':
      cwd     => "${directory}/ssl",
      command => "cat ${::ssldir}/certs/${clientcert}.pem ${::ssldir}/private_keys/${clientcert}.pem > ${directory}/ssl/combined.pem",
      creates => "${directory}/ssl/combined.pem",
      returns => [0],
      require => File["${directory}/ssl"],
      before  => Exec['mcollective-create-p12'],
    }
    file { "${directory}/ssl/combined.pem":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0400',
      require => Exec['mcollective-create-pem'],
    }
    exec { 'mcollective-create-p12':
      cwd     => "${directory}/ssl",
      command => "openssl pkcs12 -export -in combined.pem -out combined.p12 -name ${::clientcert} -passout pass:${keystore_password}",
      creates => "${directory}/ssl/combined.p12",
      returns => [0],
      require => File["${directory}/ssl/combined.pem"],
      before  => Exec['mcollective-create-keystore'],
    }
    file { "${directory}/ssl/combined.p12":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0400',
      require => Exec['mcollective-create-p12'],
    }
    exec { 'mcollective-create-keystore':
      cwd     => "${directory}/ssl",
      command => "keytool -noprompt -importkeystore -destkeystore keystore.jks -srcstoretype PKCS12 -srckeystore combined.p12 -alias '${::clientcert}' -storetype JKS -srcstorepass '${keystore_password}' -deststorepass '${keystore_password}'",
      creates => "${directory}/ssl/keystore.jks",
      returns => [0],
      require => File["${directory}/ssl"],
      before  => File["${directory}/ssl/keystore.jks"],
    }
    file { "${directory}/ssl/keystore.jks":
      ensure => file,
      owner  => $user,
      group  => 0,
      mode   => '0400',
      before => Service[ $service ],
    }

    # Truststore
    if( $brokernetwork or ( $mcollective::connector_ssl_type == 'trusted' ) ) {
      validate_re( $truststore_password, '^\S{6,}$', 'Truststore password must be at least 6 characters' )
      exec { 'mcollective-create-truststore':
        cwd     => "${directory}/ssl",
        command => "keytool -noprompt -importcert -alias '${::clientcert}' -file ${::ssldir}/certs/ca.pem -keystore ${directory}/ssl/truststore.jks -storetype JKS -storepass '${truststore_password}'",
        creates => "${directory}/ssl/truststore.jks",
        returns => [0],
        require => File["${directory}/ssl"],
        before  => File["${directory}/ssl/truststore.jks"],
      }
      file { "${directory}/ssl/truststore.jks":
        ensure => file,
        owner  => $user,
        group  => 0,
        mode   => '0400',
        before => Service[ $service ],
      }
    }

  }
}
