# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"


$szSshPackageName = "openssh"

$szJavaPkgName =  "java-1.8.0-openjdk-headless"

# Could openssh be used for both ubuntu and fedora?

package { "$szSshPackageName": ensure => present }
package { 'git': ensure => present }
#package { 'jenkins': ensure => present }
package { "$szJavaPkgName": ensure => present }

exec { 'get_jenkins_rpm':
  command => 'wget http://dm/storage/jenkins-1.625.3-1.1.noarch.rpm',
  cwd     => '/tmp',
  creates => '/tmp/jenkins-1.625.3-1.1.noarch.rpm',
  path => '/usr/bin',
}

exec { 'jenkins':
  command => 'rpm -ih /tmp/jenkins-1.625.3-1.1.noarch.rpm',
  creates => '/var/lib/jenkins',
  path => '/bin',
  require => Exec['get_jenkins_rpm'],
}

service { 'sshd': 
  ensure => running,
  enable => true,
  require => Package["$szSshPackageName"],
}

# Install Jenkins
service { 'jenkins': 
  ensure => running,
  enable => true,
  require => Exec['jenkins'],
#  require => Package['jenkins',"$szJavaPkgName"],
}

# Install Jenkins plugins.

exec { 'jenkins_rsa':
  creates  => "$szHomeDirectory/.ssh/id_rsa",
  command  => "/usr/bin/ssh-keygen -t rsa -b 2048  -q -f $szHomeDirectory/.ssh/id_rsa",
  user     => 'jenkins',
  group    => 'jenkins',
  require  => [
                Package [ "$szSshPackageName" ],
                Exec[ 'jenkins' ],
              ],
}
