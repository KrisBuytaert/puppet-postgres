# Class: postgres
#
# This module manages postgres
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class postgres {

	package { [postgresql , postgresql-server]: 
			ensure => installed,
	}


	user { 'postgres':
	    shell => '/bin/bash',
  	    ensure => 'present',
  	    comment => 'PostgreSQL Server',
 	    uid => '26',
   	    gid => '26',
   	    home => '/var/lib/pgsql',
    	    password => '!!',
	}


	group { 'postgres':
  	  ensure => 'present',
   	  gid => '26'
	}

}

define postgres::initdb {
	exec {
	   "InitDB":
		command => "/bin/su  postgres -c \"/usr/bin/initdb /var/lib/pgsql/data \"",
		require =>  User['postgres'],
		unless => "/usr/bin/test -e /var/lib/pgsql/data/postmaster.opts",
	
	}

	# Ugly hack to make sure initb runs before the hba and conf file are placed there . 
	file {  "/var/lib/pgsql/.order":
			ensure => present,
	}
}


define postgres::enable {
	service {
		postgresql:
			ensure => running,
   			enable => true,
        		hasstatus => true,
	}
}


define postgres::hba ($allowedrules){
# postgres host based authentication 

	file { "/var/lib/pgsql/data/pg_hba.conf":
		content => template("postgres/pg_hba.conf.erb"),	
		owner  => "root",
                group  => "root",
		notify => Service["postgresql"],
		require => File["/var/lib/pgsql/.order"],
	}
}

define postgres::config ($listen="localhost")  {
	file {"/var/lib/pgsql/data/postgresql.conf":
		content => template("postgres/postgresql.conf.erb"),
		owner => postgres,
		group => postgres,
		notify => Service["postgresql"],
		require => File["/var/lib/pgsql/.order"],
	}
}
