# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szMastersPublicKey = ""

package {'ssh': ensure => present }

service { 'ssh': 
  ensure => running,
  enable => true,
  require => Package['ssh'],
}

# TODO get the UID from hiera.
user { 'jenkins':
  ensure     => present,
  home       => "$szHomeDirectory",
  managehome => true,
}

file { "$szHomeDirectory/.ssh":
  ensure => directory,
  owner  => 'jenkins',
  mode   => 600,
  require => User['jenkins'],
}

file { "$szHomeDirectory/.ssh/authorized_keys":
  ensure  => file,
  owner   => 'jenkins',
  mode    => 600,
  content => "$szMastersPublicKey",
  require => [
               File["$szHomeDirectory/.ssh"],
             ],
}
