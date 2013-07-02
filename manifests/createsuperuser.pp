# == Define: postgres::createsuperuser
#
# Create a Postgres super user
define postgres::createsuperuser (
  $passwd   = undef,
  $host     = undef,
  $password = undef
) {
  sqlexec{ "Create Super User ${name}":
    host     => $host,
    password => $password,
    username => 'postgres',
    database => 'postgres',
    sql      => "CREATE USER ${name} SUPERUSER LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD '${passwd}';",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
  }
}
