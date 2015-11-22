# == Class: mcollective::facts
#
# This module sets a positive value read by facts::cronjob
#
# === Example
#
# include mcollective::facts
#
class mcollective::facts inherits mcollective::facts::cronjob {
  notice('\'mcollective::facts\' class is deprecated and will be removed in v1.0')

  Cron['mcollective-facts'] {
    ensure  => 'present',
    minute  => '*/10',
  }
}
