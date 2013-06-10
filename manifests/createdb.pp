# == Define: postgres:createdb
#
# Create a Postgres db
define postgres::createdb($owner, $password, $host) {
  sqlexec{ "Create DB ${name}":
    host     => $host,
    password => $password,
    username => 'postgres',
    database => 'postgres',
    sql      => "CREATE DATABASE ${name} WITH OWNER = ${owner} ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='${name}'\" | grep ${name}",
  }
}
