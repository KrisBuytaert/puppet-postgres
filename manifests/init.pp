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
class postgres($version = '8.4', $password = '') {
  # Handle version specified in site.pp (or default to postgresql)
  $postgres_client = "postgresql-client-${version}"
  $postgres_server = "postgresql-${version}"

  case $operatingsystem {
    debian, ubuntu: {
      class {
        'postgres::debian' :
          version => $version;
      }
    }
    default: {
      package {
        [$postgres_client, $postgres_server]:
          ensure => installed,
      }
    }
  }
}


# Initialize the database with the password password.
define postgres::initdb() {
  if $password == "" {
    exec {
      "InitDB":
        command => "/bin/chown postgres.postgres /var/lib/pgsql && /bin/su  postgres -c \"/usr/bin/initdb /var/lib/pgsql/data -E UTF8\"",
        require =>  [User['postgres'],Package["postgresql${version}-server"]],
        unless  => "/usr/bin/test -e /var/lib/pgsql/data/PG_VERSION",
    }
  } else {
    exec {
      "InitDB":
        command => "/bin/chown postgres.postgres /var/lib/pgsql && echo \"${password}\" > /tmp/ps && /bin/su  postgres -c \"/usr/bin/initdb /var/lib/pgsql/data --auth='password' --pwfile=/tmp/ps -E UTF8 \" && rm -rf /tmp/ps",
        require =>  [User['postgres'],Package["postgresql${version}-server"]],
        unless  => "/usr/bin/test -e /var/lib/pgsql/data/PG_VERSION ",
    }
  }
}

# Start the service if not running
define postgres::enable {
  service { postgresql:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Exec["InitDB"],
  }
}


# Postgres host based authentication
define postgres::hba ($password="",$allowedrules){
  file { "/var/lib/pgsql/data/pg_hba.conf":
    content   => template("postgres/pg_hba.conf.erb"),
    owner     => "root",
    group     => "root",
    notify    => Service["postgresql"],
    # require => File["/var/lib/pgsql/.order"],
    require   => Exec["InitDB"],
  }
}

define postgres::config ($listen="localhost")  {
  file {"/var/lib/pgsql/data/postgresql.conf":
    content => template("postgres/postgresql.conf.erb"),
    owner   => postgres,
    group   => postgres,
    notify => Service["postgresql"],
    # require => File["/var/lib/pgsql/.order"],
    require => Exec["InitDB"],
  }
}

# Base SQL exec
define sqlexec($username, $password, $database, $sql, $sqlcheck) {
  if $password == "" {
    exec{ "psql -h localhost --username=${username} $database -c \"${sql}\" >> /var/lib/puppet/log/postgresql.sql.log 2>&1 && /bin/sleep 5":
      path        => $path,
      timeout     => 600,
      unless      => "psql -U $username $database -c $sqlcheck",
      require     =>  [User['postgres'],Service[postgresql]],
    }
  } else {
    exec{ "psql -h localhost --username=${username} $database -c \"${sql}\" >> /var/lib/puppet/log/postgresql.sql.log 2>&1 && /bin/sleep 5":
      environment => "PGPASSWORD=${password}",
      path        => $path,
      timeout     => 600,
      unless      => "psql -U $username $database -c $sqlcheck",
      require     =>  [User['postgres'],Service[postgresql]],
    }
  }
}

# Create a Postgres user
define postgres::createuser($passwd) {
  sqlexec{ createuser:
    password => $password,
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
    password => $password,
    username => "postgres",
    database => "postgres",
    sql      => "CREATE DATABASE $name WITH OWNER = $owner ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='$name'\" | grep $name",
    require  => Service[postgresql],
  }
}
