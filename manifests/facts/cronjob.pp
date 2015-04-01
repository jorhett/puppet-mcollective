# == Class: mcollective::facts
#
# This module installs a cron script that puts Puppet facts in a file for MCollective to use
#
# === Example
#
# mcollective::facts::crontab {
#    $enable => 'present',
# }
#
class mcollective::facts::cronjob {

  # if the facts class isn't loaded, remove the cronjob
  $enable = $mcollective::facts::enable ? {
    'present'  => 'present',
    default    => 'absent',
  }

  # shorten for ease of use
  $yamlfile = "${mcollective::etcdir}/facts.yaml"

  cron { 'mcollective-facts':
    ensure  => $enable,
    command => "facter --puppet --yaml > ${yamlfile}.new && ! diff -q ${yamlfile}.new ${yamlfile} > /dev/null && mv ${yamlfile}.new ${yamlfile}",
    minute  => '*/10',
  }
}
