# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szMastersPublicKey = ""

package {'ssh': ensure => present }
package {'jenkins': ensure => present }

service { 'ssh': 
  ensure => running,
  enable => true,
  require => Package['ssh'],
}

#exec user=> jenkins generate ssh priv/pub
