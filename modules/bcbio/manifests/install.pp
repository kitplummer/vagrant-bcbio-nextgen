class bcbio::install inherits bcbio {
  
  Exec { path => [ "~/bin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
                
  case $operatingsystem {
	  /^(Debian|Ubuntu)$/:	{ include bcbio::debian }
	  'RedHat','CentOS':	{ include bcbio::redhat }
  }

  $os_lowercase = downcase($operatingsystem)

  package { "git": ensure         => installed }
  package { "gcc": ensure         => installed }
  package { "patch": ensure       => installed }

  exec { "argparse":
    command => "pip install argparse",
    require => Package["python-pip"]
  }
  
  exec { "get_bcbio":
    cwd         => "/tmp",
    user        => $user,
    environment => "USER=${user}",
    command     => "wget https://raw.github.com/chapmanb/bcbio-nextgen/master/scripts/bcbio_nextgen_install.py",
    require     => [Exec["argparse"],Package["git"]],
    creates     => "/tmp/bcbio_nextgen_install.py",
    timeout     => 300
  } ->
  exec { "install_bcbio":
    cwd         => "/tmp",
    user        => $user,
    environment => "USER=${user}",
    command     => "python /tmp/bcbio_nextgen_install.py /home/${user}/bcbio-nextgen --distribution ${os_lowercase} --tooldir=/home/${user} --nodata --isolate",
    timeout     => 10000 
  }  
}

class bcbio::debian {
  package { "libperl-dev": ensure => installed }
  package { "libexpat-dev": ensure => installed }
  package { "xz-utils": ensure  => installed }
  package { "python-pip": ensure => installed }
  package { "g++": ensure => installed }
  package { "zlib1g-dev": ensure => installed }
}

class bcbio::redhat {
  package { "perl-devel": ensure  => installed }
  package { "expat-devel": ensure => installed }
  package { "xz": ensure    => installed }
  exec {"epel":
    command => "rpm -Uvh http://mirror.umd.edu/fedora/epel/6/i386/epel-release-6-8.noarch.rpm",
    returns => [0,1]
  }
  package { "python-pip": ensure => installed, require => Exec["epel"] }
}
