# == Type: mcollective::plugin::agent
#
# This defined type loads one agent
#
# === Parameters
#
# [*version*]
#   'latest' (default) or a specific version of an agent
#
# [*dependencies*]
#   Other packages this agent depends on
#
# === Examples
#
#  mcollective::plugin::agent { 'puppet':
#    version => 'latest',
#  }
#
# Hiera (plural version implemented in mcollective::server)
#
# mcollective::plugin::agents:
#  puppet:
#    version: latest
#
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
