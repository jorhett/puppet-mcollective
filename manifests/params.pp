# == Class: mcollective::params
#
# OS-specific parameter defaults
#
class mcollective::params {
  # Default locations for certain os combinations
  $etcdir = $::clientversion ? {
    /(?:4\.)/  => '/etc/puppetlabs/mcollective',
    default    => $::osfamily ? {
      /(?i-mx:redhat)/  => '/etc/mcollective',
      /(?i-mx:debian)/  => '/etc/mcollective',
      /(?i-mx:freebsd)/ => '/usr/local/etc/mcollective',
      default           => '/etc/puppetlabs/mcollective',
    }
  }

  $logrotate_directory = $::osfamily ? {
    /(?i-mx:freebsd)/ => '/usr/local/etc/logrotate.d',
    default           => '/etc/logrotate.d',
  }

  $libdir = $::osfamily ? {
    /(?i-mx:redhat)/  => '/usr/libexec/mcollective',
    /(?i-mx:debian)/  => '/usr/share/mcollective/plugins',
    /(?i-mx:freebsd)/ => '/usr/local/share',
    default           => '/usr/libexec/mcollective',
  }

  # Stomp Package
  $stomp_package = $::osfamily ? {
    /(?i-mx:redhat)/  => 'rubygem-stomp',
    /(?i-mx:debian)/  => 'ruby-stomp',
    /(?i-mx:freebsd)/ => 'devel/rubygem-stomp',
    default           => 'rubygem-stomp',
  }

  # Package and service names
  $package_name = $::osfamily ? {
    /(?i-mx:redhat)/  => 'mcollective',
    /(?i-mx:debian)/  => 'mcollective',
    /(?i-mx:freebsd)/ => 'sysutils/mcollective',
    default           => 'mcollective',
  }

  $client_package_name = $::osfamily ? {
    /(?i-mx:redhat)/  => 'mcollective-client',
    /(?i-mx:debian)/  => 'mcollective-client',
    /(?i-mx:freebsd)/ => 'sysutils/mcollective-client',
    default           => 'mcollective-client',
  }

  $service_name = $::osfamily ? {
    /(?i-mx:redhat)/  => 'mcollective',
    /(?i-mx:debian)/  => 'mcollective',
    /(?i-mx:freebsd)/ => 'mcollectived',
    default           => 'mcollective-client',
  }

  # Logfile locations (all platforms seem identical for this for now)
  $logfile = '/var/log/mcollective.log'

  # These appear to be the same for all platforms
  $activemq_config_file  = 'activemq.xml'
  $activemq_service_name = 'activemq'
  $activemq_user_name    = 'activemq'

  $activemq_package_name = $::osfamily ? {
    /(?i-mx:redhat)/  => 'activemq',
    /(?i-mx:debian)/  => 'activemq',
    /(?i-mx:freebsd)/ => 'net/activemq',
    default           => 'activemq',
  }

  $activemq_directory = $::osfamily ? {
    /(?i-mx:redhat)/  => '/etc/activemq',
    /(?i-mx:debian)/  => '/etc/activemq',
    /(?i-mx:freebsd)/ => '/usr/local/etc/activemq',
    default           => '/etc/activemq',
  }

  $activemq_defaults_file = $::osfamily ? {
    /(?i-mx:redhat)/  => '/etc/sysconfig/activemq',
    /(?i-mx:debian)/  => '/etc/default/activemq',
    /(?i-mx:freebsd)/ => undef,
    default           => undef,
  }
}
