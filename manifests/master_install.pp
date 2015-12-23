# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szJenkinsPluginDir = "$szHomeDirectory/plugins"

$szSshPackageName = "openssh"

$szJavaPkgName =  "java-1.8.0-openjdk-headless"

# Could openssh be used for both ubuntu and fedora?

package { "$szSshPackageName": ensure => present }
package { 'git': ensure => present }
#package { 'jenkins': ensure => present }
package { "$szJavaPkgName": ensure => present }

service { 'sshd': 
  ensure => running,
  enable => true,
  require => Package["$szSshPackageName"],
}

exec { 'get_jenkins_rpm':
  command => 'wget http://dm/storage/jenkins-1.625.3-1.1.noarch.rpm',
  cwd     => '/tmp',
  creates => '/tmp/jenkins-1.625.3-1.1.noarch.rpm',
  path => '/usr/bin',
}

# Install Jenkins
exec { 'jenkins':
  command => 'rpm -ih /tmp/jenkins-1.625.3-1.1.noarch.rpm',
  creates => '/var/lib/jenkins',
  path => '/bin',
  require => Exec['get_jenkins_rpm'],
}

service { 'jenkins': 
  ensure => running,
  enable => true,
  require => Exec['jenkins'],
#  require => Package['jenkins',"$szJavaPkgName"],
}


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

# Install Jenkins plugins.
# TODO get the list of plugins from hiera.
exec { 'greenballs_plugin':
  creates => "$szJenkinsPluginDir/greenballs.hpi",
  command => "wget http://dm/storage/jenkins/greenballs.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# Generate usage graphs for the jenknis server and nodes.
# You can access it at: :8080/monitoring and :8080/monitoring/nodes
exec { 'monitoring_plugin':
  creates => "$szJenkinsPluginDir/monitoring.hpi",
  command => "wget http://dm/storage/jenkins/monitoring.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

exec { 'disk-usage_plugin':
  creates => "$szJenkinsPluginDir/disk-usage.hpi",
  command => "wget http://dm/storage/jenkins/disk-usage.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# required by build-flow-plugin
exec { 'buildgraph-view_plugin':
  creates => "$szJenkinsPluginDir/buildgraph-view.hpi",
  command => "wget http://dm/storage/jenkins/buildgraph-view.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# Allow configuration of flows and parallel tasks.
exec { 'build-flow-plugin_plugin':
  creates => "$szJenkinsPluginDir/build-flow-plugin.hpi",
  command => "wget http://dm/storage/jenkins/build-flow-plugin.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# required by test-results-analyzer
exec { 'junit_plugin':
  creates => "$szJenkinsPluginDir/junit.hpi",
  command => "wget http://dm/storage/jenkins/junit.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# 
exec { 'testng-plugin_plugin':
  creates => "$szJenkinsPluginDir/testng-plugin.hpi",
  command => "wget http://dm/storage/jenkins/testng-plugin.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

# Allow tracking of test results.
exec { 'test-results-analyzer_plugin':
  creates => "$szJenkinsPluginDir/test-results-analyzer.hpi",
  command => "wget http://dm/storage/jenkins/test-results-analyzer.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => Exec['jenkins'],
  notify  => Service['jenkins'],
}

