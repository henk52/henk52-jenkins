# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szMastersPublicKey = ""

$szSshPackageName = "ssh"
# Could openssh be used for both ubuntu and fedora?

package { "$szSshPackageName": ensure => present }
package { 'jenkins': ensure => present }

service { 'ssh': 
  ensure => running,
  enable => true,
  require => Package['ssh'],
}

#exec user=> jenkins generate ssh priv/pub

exec { 'jenkins_rsa':
  creates  => "$szHomeDirectory/.ssh/id_rsa",
  command  => "/usr/bin/ssh-keygen -t rsa -b 2048  -q -f $szHomeDirectory/.ssh/id_rsa",
  user     => 'jenkins',
  group    => 'jenkins',
  require  => [
                Package [ "$szSshPackageName" ],
                File [ "$szHomeDirectory/.ssh" ],
              ],
}
