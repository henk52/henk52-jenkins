# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szMastersPublicKey = hiera("MastersPublicKey")

$szSshPackageName = "openssh"


package {"$szSshPackageName": ensure => present }

# Jenkins pushes a .jar file onto the node, even when the node is set-up as an ssh node.
package {'openjdk-7-jre-headless': ensure => present }


service { 'sshd': 
  ensure => running,
  enable => true,
  require => Package["$szSshPackageName"],
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

