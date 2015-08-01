# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"


$szSshPackageName = "ssh"
# Could openssh be used for both ubuntu and fedora?

package { "$szSshPackageName": ensure => present }
package { 'git': ensure => present }
package { 'jenkins': ensure => present }

service { 'ssh': 
  ensure => running,
  enable => true,
  require => Package['ssh'],
}

# Install Jenkins
service { 'ssh': 
  ensure => running,
  enable => true,
  require => Package['jenkins'],
}

# Install Jenkins plugins.

exec { 'jenkins_rsa':
  creates  => "$szHomeDirectory/.ssh/id_rsa",
  command  => "/usr/bin/ssh-keygen -t rsa -b 2048  -q -f $szHomeDirectory/.ssh/id_rsa",
  user     => 'jenkins',
  group    => 'jenkins',
  require  => [
                Package [ "$szSshPackageName" ],
                Service [ 'jenkins' ],
                File [ "$szHomeDirectory/.ssh" ],
              ],
}
