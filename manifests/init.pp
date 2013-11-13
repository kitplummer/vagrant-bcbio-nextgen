file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

Exec { path => [ "~/bin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
                
package { "git": ensure => installed }
package { "gcc": ensure => installed }
package { "perl-devel": ensure => installed }
package { "expat-devel": ensure => installed }
package { "patch": ensure => installed }
package { "xz": ensure => installed }

exec {"epel":
  command => "rpm -Uvh http://mirror.umd.edu/fedora/epel/6/i386/epel-release-6-8.noarch.rpm",
  returns => [0,1]
}

package { "python-pip": ensure => installed, require => Exec["epel"] }

exec { "argparse":
  command => "pip install argparse",
  require => Package["python-pip"]
}

exec { "get_bcbio":
  cwd         => "/tmp",
  user        => "vagrant",
  environment => "USER=vagrant",
  command     => "wget https://raw.github.com/chapmanb/bcbio-nextgen/master/scripts/bcbio_nextgen_install.py",
  require     => [Exec["argparse"],Package["git"]],
  creates     => "/tmp/bcbio_nextgen_install.py",
  timeout     => 300
} ->
exec { "install_bcbio":
  cwd         => "/tmp",
  user        => "vagrant",
  environment => "USER=vagrant",
  command     => "python bcbio_nextgen_install.py /home/vagrant/bcbio-nextgen --distribution centos --tooldir=/home/vagrant --isolate",
  timeout     => 10000 
}  
