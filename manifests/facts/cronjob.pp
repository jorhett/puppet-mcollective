# == Class: mcollective::facts
#
# This module installs a cron script that puts Puppet facts in a file for MCollective to use
#
# === Example
#
# mcollective::facts::cronjob {
#    $runevery,
# }
#
class mcollective::facts::cronjob(
  $run_every = 'unknown',
) {

  # if they passed in Hiera value use that.
  if( $run_every != 'unknown' ) {
    $enable = $run_every ? {
      undef   => 'absent',
      ''      => 'absent',
      default => 'present',
    }
    $minute = "*/${run_every}"
  }
  else {
    # Otherwise fall back to looking up value (won't work in Puppet 4)
    $enable = $mcollective::facts::enable ? {
      'present' => 'present',
      default   => 'absent',
    }
    $minute = '*/10'
  }

  # shorten for ease of use
  $yamlfile = "${mcollective::etcdir}/facts.yaml"

  cron { 'mcollective-facts':
    ensure  => $enable,
    command => "facter --puppet --yaml > ${yamlfile}.new && ! diff -q ${yamlfile}.new ${yamlfile} > /dev/null && mv ${yamlfile}.new ${yamlfile}",
    minute  => $minute,
  }
}
