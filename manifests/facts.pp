# == Class: mcollective::facts
#
# This module sets a positive value read by facts::cronjob
#
# === Example
#
# include mcollective::facts
#
# === DEPRECATED
#   use hiera value mcollective::facts::cronjob::run_every instead
#

# This looks weird, huh? Going away soon.
class mcollective::facts inherits mcollective::facts::cronjob {

  # Just in case they define the variable and include the class both
  if( ! $mcollective::facts::cronjob::run_every ) {
    # Override to enable and set minutes
    Cron['mcollective-facts'] { 
      ensure => present,
      minute => '*/10',
    }
  }
}
