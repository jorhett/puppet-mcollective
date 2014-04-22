define mcollective::plugin::actionpolicy(
  $agent   = $name,
  $default = 'allow',
  $rules,
) {

  # The template iterates through the rules
  file { "${mcollective::etcdir}/policies/${agent}.policy":                                                                                                                                                               
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => 0440,
    replace => true,
    content => template( 'mcollective/agent.policy.erb' ),
  } 
}
