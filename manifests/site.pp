
class bitcoind::ppa
{

    $repository = "ppa:bitcoin/bitcoin"

    exec { "update apt-get for system": 
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "apt-get update",
        logoutput => false,
    } 

    exec { "add-apt-repository ppa:bitcoin/bitcoin":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "add-apt-repository -y ${repository}",
        logoutput => false,
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
        returns		=> [0, 1],
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
        returns		=> [0, 1],
        require   => File['/home/vagrant/.bitcoin/bitcoin.conf'],
    }
}

class nodejs::ppa
{
    exec { "add-apt-repository ppa:chris-lea/node.js":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "add-apt-repository -y ppa:chris-lea/node.js",
        logoutput => false,
        require   => Class['bitcoind::start'],
        notify    => Exec['update apt-get for nodejs'],
    }

    exec { "update apt-get for nodejs":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command   => "apt-get update",
        logoutput => false,
        require   => Exec['add-apt-repository ppa:chris-lea/node.js'],
    }

		package { ["python", "g++", "make", "nodejs"]:
        ensure  => present,
        require   => Exec['update apt-get for nodejs']
    }
}

class insight::install
{
	package { ["git"]:
        ensure => present,
        require => Class['nodejs::ppa']
	}

	exec { "git-clone-insight":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command 	=> "git clone https://github.com/acejam/insight.git",
        cwd 			=> "/srv",
        creates => "/srv/insight",
        require 	=> Package['git']
	}

	exec { "insight-install":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        command => "npm install",
        logoutput => true,
        cwd 		=> "/srv/insight",
        require => Exec['git-clone-insight']
	}

    file { "/srv/insight/node_modules/insight-bitcore-api/db":
        ensure => directory,
        require => Exec['insight-install']
    }

	exec { "insight-start":
        path      => "/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:.",
        environment => ["NODE_ENV=production", "INSIGHT_NETWORK=livenet", "BITCOIND_USER=user", "BITCOIND_PASS=password", "BITCOIND_DATADIR=/home/vagrant/.bitcoin/", "INSIGHT_PUBLIC_PATH=public", "INSIGHT_DB=/srv/insight/node_modules/insight-bitcore-api/db" ],
        command => "nohup npm start &",
        cwd			=> "/srv/insight",
        logoutput => true,
        require => File['/srv/insight/node_modules/insight-bitcore-api/db']
	}
}

include bitcoind::ppa
include bitcoind::install
include bitcoind::start
include nodejs::ppa
include insight::install