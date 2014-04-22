define mcollective::plugin::client (
    $version      = 'latest',
    $dependencies = [],
) {
  package { "mcollective-${name}-client": 
    ensure  => $version,
    require => [ Package[$mcollective::client::package], $dependencies],
  }
}
