# == Fact: ssldir
#
# A custom fact that gets the puppet client's SSLdir
#
Facter.add("ssldir") do
  setcode do
    Puppet[:ssldir]
  end
end
