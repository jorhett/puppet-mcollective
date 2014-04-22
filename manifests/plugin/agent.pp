define mcollective::plugin::agent(
    $version      = 'latest',
    $dependencies = [],
) {
  package { "mcollective-${name}-agent": 
    ensure  => $version,
    require => [ Package[$mcollective::server::package], $dependencies],
    notify  => Service[ $mcollective::service_name ],
  }
}
