# == Define: postgres::createuser
#
# Create a Postgres user
define postgres::createuser (
  $passwd   = undef,
  $host     = undef,
  $password = undef
) {
  sqlexec{ "Create User ${name}":
    host     => $host,
    password => $password,
    username => 'postgres',
    database => 'postgres',
    sql      => "CREATE ROLE ${name} WITH LOGIN PASSWORD '${passwd}';",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
  }
}
