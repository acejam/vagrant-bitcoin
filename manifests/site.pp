
Exec { path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:/sbin" }

class system::update
{
    exec { "update apt-get for system": 
        command   => "apt-get update",
    }

    exec { "upgrade apt-get for system":
        command   => "/usr/bin/apt-get --quiet --yes --fix-broken upgrade",
        require   => Exec['update apt-get for system'],
    }
}

class nodejs::install
{
    package { ["build-essential", "libssl-dev", "git"]:
        ensure    => present,
        require   => Class['system::update'],
    }

    exec { "install nodesource":
        command   => "curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -",
        require   => Package["build-essential", "libssl-dev", "git"],
    }

    package { ["nodejs"]:
        ensure    => present,
        require   => Exec['install nodesource'],
    }
}

class insight::install
{
    exec { "install bitcore-node":
        command  => "sudo npm install -g bitcore-node",
        cwd      => "/home/vagrant",
        require  => Class['nodejs::install'],
    }

    exec { "create mynode":
        command  => "sudo /usr/bin/bitcore-node create mynode",
        cwd      => "/home/vagrant",
        creates  => "/home/vagrant/mynode",
        require  => Exec['install bitcore-node'],
    }

    exec { "install insight-api":
        command  => "sudo /usr/bin/bitcore-node install insight-api",
        cwd      => "/home/vagrant/mynode",
        require  => Exec['create mynode'],
    }

    exec { "install insight-ui":
        command  => "sudo /usr/bin/bitcore-node install insight-ui",
        cwd      => "/home/vagrant/mynode",
        require  => Exec['install insight-api'],
    }

    exec { "start bitcore":
        command  => "screen -d -m -S node sudo /usr/bin/bitcore-node start",
        cwd      => "/home/vagrant/mynode",
        require  => Exec['install insight-ui'],
    }

}

include system::update
include nodejs::install
include insight::install