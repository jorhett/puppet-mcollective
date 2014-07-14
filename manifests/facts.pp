# == Class: mcollective::facts
#
# This module stores Puppet facts in a file for MCollective to use
#
# === Example
#
# include mcollective::facts
#
class mcollective::facts {
  include mcollective

  # By generating facts.yaml in its own dedicated class, the file isn't polluted with unwanted in scope class variables.

  # Bring in variables from other classes here.
  # This makes them available to mcollective for use in fact filters (-wf -F)
  #
  #$class_variable = $class::variable

  # mcollective doesn't work with arrays, so use the puppet-stdlib join function
  #$ntp_servers = join($ntp::servers, ",")

  file { "${mcollective::etcdir}/facts.yaml":
    owner   => 0,
    group   => 0,
    mode    => '0400',
    content => template('mcollective/facts.yaml.erb'),
  }
}
