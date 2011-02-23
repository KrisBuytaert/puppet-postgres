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
# Sample Usage: see postgres/README.markdown
#
# [Remember: No empty lines between comments and class definition]
class postgres {
  # Common stuff, like ensuring postgres_password defined in site.pp
  include postgres::common

  # Handle version specified in site.pp (or default to postgresql) 
  $postgres_client = "postgresql${postgres_version}"
  $postgres_server = "postgresql${postgres_version}-server"

  package { [$postgres_client, $postgres_server]: 
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

# Initialize the database with the postgres_password password.
define postgres::initdb {
  if $postgres_password == "" {
    exec {
        "InitDB":
          command => "/bin/su  postgres -c \"/usr/bin/initdb /var/lib/pgsql/data -E UTF8\"",
          require =>  [User['postgres'],Package["postgresql${postgres_version}-server"]],
          unless => "/usr/bin/test -e /var/lib/pgsql/data/postmaster.opts",
    }
    # Ugly hack to make sure initb runs before the hba and conf file are placed there . 
    file {  "/var/lib/pgsql/.order":
      ensure => present,
      require => Package["postgresql${postgres_version}-server"],
    }
  } else {
    exec {
        "InitDB":
          command => "echo \"${postgres_password}\" > /tmp/ps && /bin/su  postgres -c \"/usr/bin/initdb /var/lib/pgsql/data --auth='password' --pwfile=/tmp/ps -E UTF8 \" && rm -rf /tmp/ps",
          require =>  [User['postgres'],Package["postgresql${postgres_version}-server"]],
          unless => "/usr/bin/test -e /var/lib/pgsql/data/postmaster.opts",
    }
    # Ugly hack to make sure initb runs before the hba and conf file are placed there . 
    file {  "/var/lib/pgsql/.order":
      ensure => present,
      require => Package["postgresql${postgres_version}-server"],
    }
  }
}

# Start the service if not running
define postgres::enable {
  service { postgresql:
    ensure => running,
    enable => true,
    hasstatus => true,
    require => File["/var/lib/pgsql/.order"],
  }
}


# Postgres host based authentication 
define postgres::hba ($allowedrules){
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

# Base SQL exec
define sqlexec($username, $password, $database, $sql, $sqlcheck) {
  exec{ "psql -h localhost --username=${username} $database -c \"${sql}\" >> /var/lib/puppet/log/postgresql.sql.log 2>&1 && /bin/sleep 5":
    environment => "PGPASSWORD=${postgres_password}",
    path        => $path,
    timeout     => 600,
    unless      => "psql -U $username $database -c $sqlcheck",
    require =>  [User['postgres'],Service[postgresql]],
  }
}

# Create a Postgres user
define postgres::createuser($passwd) {
  sqlexec{ createuser:
    password => $postgres_password, 
    username => "postgres",
    database => "postgres",
    sql      => "CREATE ROLE ${name} WITH LOGIN PASSWORD '${passwd}';",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
    require  =>  Service[postgresql],
  }
}

# Create a Postgres db
define postgres::createdb($owner) {
  sqlexec{ $name:
    password => $postgres_password, 
    username => "postgres",
    database => "postgres",
    sql => "CREATE DATABASE $name WITH OWNER = $owner ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='$name'\" | grep $name",
    require => Service[postgresql],
  }
}
