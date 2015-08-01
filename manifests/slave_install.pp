# Get the masters public key via Hiera.

$szHomeDirectory = "/var/lib/jenkins"
$szMastersPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCucLk2z55RZ/Ms0Vs/Ms/LqzdwhH2hDq1P253nlJxTKbRkSCrfsgLakoPWRBP/7QKkBOJUy47/w6sArXbyiTqZW3N+CEsDkp+sbH7Nzv9+8ILCvU4XdsETiWGG07o+u2gqWsNOYiFaS6CG6Mp0IZHnoEKRv/dNI49i8PGMX/NKBcLRR7/XTfWXKEe4O983b/cC8gpIVo+AI0dWsLYqi5PMaJCspexPOq8guNj9BEFyRc7oTorcKS7sO27NZzDnWyk833uKbgV32vcu5gIAzxT/lrpiHKbXfyIt61uaz3tEhZN8O48+RPx7gjklfYE+1mNOmvZHpKqDmt39BWxk82e9 jenkins@master"

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
