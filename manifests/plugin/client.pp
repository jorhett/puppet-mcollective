# == Type: mcollective::plugin::client
#
# This defined type loads one client application
#
# === Parameters
#
# [*version*]
#   'latest' (default) or a specific version of an client
#
# [*dependencies*]
#   Other packages this client depends on
#
# === Examples
#
#  mcollective::plugin::client: { 'puppet':
#    version => 'latest',
#  }
#
# Hiera (plural version implemented in mcollective::client)
#
# mcollective::plugin::clients:
#  puppet:
#    version: latest
#
define mcollective::plugin::client (
    $version      = 'latest',
    $dependencies = [],
) {
  package { "mcollective-${name}-client":
    ensure  => $version,
    require => [ Package[$mcollective::client::package], $dependencies],
  }
}
