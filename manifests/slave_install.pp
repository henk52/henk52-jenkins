# Get the masters public key via Hiera.

$szJenkinsUserName = hiera("JenkinsUserName", 'jenkins')
$szHomeDirectory = hiera("JenkinsHomeDir", "/var/lib/$szJenkinsUserName")
$szMastersPublicKey = hiera("MastersPublicKey")

$szSshPackageName = "openssh"


package {"$szSshPackageName": ensure => present }

# Jenkins pushes a .jar file onto the node, even when the node is set-up as an ssh node.
if ( $operatingsystemrelease == '23' ) {
  package {'java-1.8.0-openjdk-headless': ensure => present }
} else {
  package {'openjdk-7-jre-headless': ensure => present }
}


service { 'sshd': 
  ensure => running,
  enable => true,
  require => Package["$szSshPackageName"],
}

# TODO get the UID from hiera.
user { "$szJenkinsUserName":
  ensure     => present,
  home       => "$szHomeDirectory",
  managehome => true,
}

file { "$szHomeDirectory/.ssh":
  ensure => directory,
  owner  => "$szJenkinsUserName",
  mode   => '600',
  require => User["$szJenkinsUserName"],
}

file { "$szHomeDirectory/.ssh/authorized_keys":
  ensure  => file,
  owner  => "$szJenkinsUserName",
  mode    => '600',
  content => "$szMastersPublicKey",
  require => [
               File["$szHomeDirectory/.ssh"],
             ],
}

