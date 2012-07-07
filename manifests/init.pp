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
class postgres(
  $version = '9.0',
  $short_version = '90',
  $password = '',
  $running_ip = '127.0.0.1',
) {
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
    CentOS: {
      class {
        'postgres::centos' :
          version       => $version,
          short_version => $short_version,
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
define postgres::initdb($version = "9.0", $short_version = "90", $password = "") {
  if $password == "" {
    exec {
      "InitDB":
        command => "/bin/chown postgres.postgres /var/lib/pgsql && /bin/su  postgres -c \"/usr/pgsql-${version}/bin/initdb /var/lib/pgsql/${version}/data -E UTF8\"",
        require =>  Package["postgresql${short_version}-server"],
        creates => "/var/lib/pgsql/${version}/data/PG_VERSION",
    }
  } else {
    exec {
      "InitDB":
        command => "/bin/chown postgres.postgres /var/lib/pgsql && echo \"${password}\" > /tmp/ps && /bin/su  postgres -c \"/usr/pgsql-${version}/bin/initdb /var/lib/pgsql/${$version}/data --auth='password' --pwfile=/tmp/ps -E UTF8 \" && rm -rf /tmp/ps",
        require =>  Package["postgresql${short_version}-server"],
        creates => "/var/lib/pgsql/${version}/data/PG_VERSION",
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
define postgres::hba ($allowedrules, $version="9.0", $password = ""){
  file { "/var/lib/pgsql/${version}/data/pg_hba.conf":
    content   => template("postgres/pg_hba.conf.erb"),
    owner     => "root",
    group     => "root",
  }
}

define postgres::config ($listen="localhost")  {
  file {"/var/lib/pgsql/data/postgresql.conf":
    content => template("postgres/postgresql.conf.erb"),
    owner   => postgres,
    group   => postgres,
    notify  => Service["postgresql"],
    # require => File["/var/lib/pgsql/.order"],
    require => Exec["InitDB"],
  }
}

# Base SQL exec
define sqlexec($username, $password, $database, $sql, $sqlcheck, $host="localhost") {
  if $password == "" {
    exec{ "psql -h ${host} --username=${username} $database -c \"${sql}\" && /bin/sleep 5":
      path      => $::path,
      timeout   => 600,
      unless    => "psql -h ${host} -U $username $database -c $sqlcheck",
      logoutput => true,
    }
  } else {
    exec{ "psql -h ${host} --username=${username} $database -c \"${sql}\" && /bin/sleep 5":
      environment => "PGPASSWORD=${password}",
      path        => $::path,
      timeout     => 600,
      unless      => "psql -h ${host} -U $username $database -c $sqlcheck",
      logoutput   => true,
    }
  }
}

# Create a Postgres user
define postgres::createuser($passwd, $host, $password) {
  sqlexec{ "Create User $name":
    host     => $host,
    password => $password,
    username => "postgres",
    database => "postgres",
    sql      => "CREATE ROLE ${name} WITH LOGIN PASSWORD '${passwd}';",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
  }
}

# Create a Postgres super user
define postgres::createsuperuser($passwd, $host, $password) {
  sqlexec{ "Create Super User $name":
    host     => $host,
    password => $password,
    username => "postgres",
    database => "postgres",
    sql      => "CREATE USER ${name} SUPERUSER LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD '${passwd}';",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
  }
}

# Create a Postgres db
define postgres::createdb($owner, $password, $host) {
  sqlexec{ "Create DB $name":
    host     => $host,
    password => $password,
    username => "postgres",
    database => "postgres",
    sql      => "CREATE DATABASE $name WITH OWNER = $owner ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='$name'\" | grep $name",
  }
}
