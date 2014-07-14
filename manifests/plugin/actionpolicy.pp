# == Type: mcollective::plugin::actionpolicy
#
# This defined type creates an actionpolicy file for one agent
#
# === Parameters
#
# [*agent*]
#   Name of the agent
#
# [*default*]
#   Allow (default) or Deny
#
# [*rules*]
#   A hash of rules to implement
#
# === Examples
#
#  mcollective::plugin::actionpolicy { 'puppet':
#    default => 'deny',
#  }
#
# Hiera
# puppet:
#   default: deny
#   rules:
#     'get out of jail free':
#       policy : allow
#       caller : *
#       actions: *
#       facts  : *
#       classes: *
#
define mcollective::plugin::actionpolicy(
  $agent   = $name,
  $default = 'allow',
  $rules   = {},
) {

  # The template iterates through the rules
  file { "${mcollective::etcdir}/policies/${agent}.policy":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0440',
    replace => true,
    content => template( 'mcollective/agent.policy.erb' ),
  }
}
