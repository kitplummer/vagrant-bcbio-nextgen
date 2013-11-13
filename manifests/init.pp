file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
              Managed by Puppet.\n"
}
class { "bcbio": user => "stack" }
class { "bcbio::install": }


