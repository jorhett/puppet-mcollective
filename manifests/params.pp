class mcollective::params {
  # Default locations for certain os combinations
  $etcdir = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => '/etc/mcollective',
     /(?i-mx:ubuntu|debian)/        => '/etc/mcollective',
     /(?i-mx:freebsd)/              => '/usr/local/etc/mcollective',
  }

  $libdir = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => '/usr/libexec/mcollective',
     /(?i-mx:ubuntu|debian)/        => '/usr/share/mcollective/plugins',
     /(?i-mx:freebsd)/              => '/usr/local/share',
  }

  # Stomp Package
  $stomp_package = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => 'rubygem-stomp',
     /(?i-mx:ubuntu|debian)/        => 'ruby-stomp',
     /(?i-mx:freebsd)/              => 'devel/rubygem-stomp'
  }

  # Package and service names
  $package_name = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => 'mcollective',
     /(?i-mx:ubuntu|debian)/        => 'mcollective',
     /(?i-mx:freebsd)/              => 'sysutils/mcollective',
  }

  $client_package_name = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => 'mcollective-client',
     /(?i-mx:ubuntu|debian)/        => 'mcollective-client',
     /(?i-mx:freebsd)/              => 'sysutils/mcollective-client',
  }

  $service_name = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => 'mcollective',
     /(?i-mx:ubuntu|debian)/        => 'mcollective',
     /(?i-mx:freebsd)/              => 'mcollectived',
  }

  # Logfile locations (all platforms seem identical for this for now)
  $logfile = '/var/log/mcollective.log'

  # These appear to be the same for all platforms
  $activemq_config_file     = 'activemq.xml'
  $activemq_service_name    = 'activemq'
  $activemq_user_name       = 'activemq'

  $activemq_package_name = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => 'activemq',
     /(?i-mx:ubuntu|debian)/        => 'activemq',
     /(?i-mx:freebsd)/              => 'net/activemq',
  }

  $activemq_directory = $::osfamily ? {
     /(?i-mx:centos|fedora|redhat)/ => '/etc/activemq',
     /(?i-mx:ubuntu|debian)/        => '/etc/activemq',
     /(?i-mx:freebsd)/              => '/usr/local/etc/activemq',
  }
}
