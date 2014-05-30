
class bitcoind::ppa
{
    #include bitcoind::params

    $repository = "ppa:bitcoin/bitcoin"

    exec { "update apt-get for system": 
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "apt-get update",
        logoutput => false,
    } 

    exec { "add-apt-repository ppa:bitcoin/bitcoin":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "add-apt-repository -y ${repository}",
        logoutput => true,
        require   => Exec['update apt-get for system'],
        notify    => Exec['update apt-get for bitcoin'],
    }

    exec { "update apt-get for bitcoin": 
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "apt-get update",
        logoutput => false,
        require   => Exec['add-apt-repository ppa:bitcoin/bitcoin'],
    }

    package { "python-software-properties":
        ensure  => present,
        require   => Exec['update apt-get for system'],
        before  => Exec["add-apt-repository ppa:bitcoin/bitcoin"]
    }

}

class bitcoind::install
{
		package { "bitcoind":
        ensure  => present,
        require   => Class['bitcoind::ppa']
    }
}

class bitcoind::start
{
    exec { "start-bitcoin-1": 
        command   => "su - vagrant -c 'bitcoind'",
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        returns		=> 1,
        require   => Class['bitcoind::install'],
    }

    file { "/home/vagrant/.bitcoin/bitcoin.conf":
    		ensure => file,
    		owner => 'vagrant',
    		group => 'vagrant',
    		source => '/vagrant/bitcoin.conf',
    		require => Exec['start-bitcoin-1']
		}

    exec { "start-bitcoin-2": 
        command   => "su - vagrant -c 'bitcoind -reindex'",
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        returns		=> 0,
        require   => File['/home/vagrant/.bitcoin/bitcoin.conf'],
    }
}

include bitcoind::ppa
include bitcoind::install
include bitcoind::start