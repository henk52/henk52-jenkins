# == Class: jenkins
#
# Full description of class jenkins here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { jenkins:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class jenkins {

$szSshPackageName = "openssh"


# Jenkins pushes a .jar file onto the node, even when the node is set-up as an ssh node.
if ( $operatingsystemrelease == '23' ) {
  package {'java-1.8.0-openjdk-headless': ensure => present }
} else {
  package {'openjdk-7-jre-headless': ensure => present }
}


# TODO change the name from home dir to eg. ServerBaseDir
$szHomeDirectory = '/var/lib/jenkins'
$szJenkinsPluginDir = "$szHomeDirectory/plugins"

# Could openssh be used for both ubuntu and fedora?

package { "$szSshPackageName": ensure => present }
package { 'git': ensure => present }

# According to http://vault-tec.info/post/98877792626/jenkins-service-unavailable
#  the issue of jenkins doing the 503 is fixed when this package is installed:
package { 'fontconfig': ensure => present }


service { 'sshd': 
  ensure => running,
  enable => true,
  require => Package["$szSshPackageName"],
}

exec { 'get_jenkins_rpm':
  command => 'wget http://dm/storage/jenkins/jenkins-1.625.3-1.1.noarch.rpm',
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
  require => [
               Exec['jenkins'],
               Package['fontconfig']
             ],
#  require => Package['jenkins',"$szJavaPkgName"],
}


exec { 'jenkins_rsa':
  creates  => "$szHomeDirectory/.ssh/id_rsa",
  command  => "/usr/bin/ssh-keygen -t rsa -b 2048  -q -f $szHomeDirectory/.ssh/id_rsa",
  user     => 'jenkins',
  group    => 'jenkins',
  require  => [
                Package[ "$szSshPackageName" ],
                Exec[ 'jenkins' ],
              ],
}

# TODO make all plugins dependent on this.
file { "$szJenkinsPluginDir":
  ensure => directory,
  owner  => 'jenkins',
  require => Exec['jenkins'],
}

# Install Jenkins plugins.
# TODO get the list of plugins from hiera.
exec { 'greenballs_plugin':
  creates => "$szJenkinsPluginDir/greenballs.hpi",
  command => "wget http://dm/storage/jenkins/greenballs.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# Generate usage graphs for the jenknis server and nodes.
# You can access it at: :8080/monitoring and :8080/monitoring/nodes
exec { 'monitoring_plugin':
  creates => "$szJenkinsPluginDir/monitoring.hpi",
  command => "wget http://dm/storage/jenkins/monitoring.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

exec { 'disk-usage_plugin':
  creates => "$szJenkinsPluginDir/disk-usage.hpi",
  command => "wget http://dm/storage/jenkins/disk-usage.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# required by build-flow-plugin
exec { 'buildgraph-view_plugin':
  creates => "$szJenkinsPluginDir/buildgraph-view.hpi",
  command => "wget http://dm/storage/jenkins/buildgraph-view.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# Allow configuration of flows and parallel tasks.
exec { 'build-flow-plugin_plugin':
  creates => "$szJenkinsPluginDir/build-flow-plugin.hpi",
  command => "wget http://dm/storage/jenkins/build-flow-plugin.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# required by test-results-analyzer
exec { 'junit_plugin':
  creates => "$szJenkinsPluginDir/junit.hpi",
  command => "wget http://dm/storage/jenkins/junit.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# 
exec { 'testng-plugin_plugin':
  creates => "$szJenkinsPluginDir/testng-plugin.hpi",
  command => "wget http://dm/storage/jenkins/testng-plugin.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# Allow tracking of test results.
exec { 'test-results-analyzer_plugin':
  creates => "$szJenkinsPluginDir/test-results-analyzer.hpi",
  command => "wget http://dm/storage/jenkins/test-results-analyzer.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

# Enable auditing changes to jobs etc.
exec { 'audit-trail_plugin':
  creates => "$szJenkinsPluginDir/audit-trail.hpi",
  command => "wget http://dm/storage/jenkins/audit-trail.hpi",
  cwd     => "$szJenkinsPluginDir",
  path    => '/usr/bin',
  require => File["$szJenkinsPluginDir"],
  notify  => Service['jenkins'],
}

} # end class.

