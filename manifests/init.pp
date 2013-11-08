file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
                
exec {"epel":
  command => "rpm -Uvh http://mirror.umd.edu/fedora/epel/6/i386/epel-release-6-8.noarch.rpm",
  returns => [0,1]
}

package { "python-pip": ensure => installed, require => Exec["epel"] }

exec { "argparse":
  command => "pip install argparse",
  require => Package["python-pip"]
}

exec { "bcbio":
  cwd     => "/tmp",
  command => "wget https://raw.github.com/chapmanb/bcbio-nextgen/master/scripts/bcbio_nextgen_install.py; python bcbio_nextgen_install.py /usr/local/share/bcbio-nextgen --tooldir=/usr/local",
  require => [Exec["argparse"]]
}
