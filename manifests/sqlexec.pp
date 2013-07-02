# == Define: postgres::sqlexec
#
# Base SQL exec
define postgres::sqlexec (
  $username,
  $password,
  $database,
  $sql,
  $sqlcheck,
  $host = 'localhost'
) {
  if $password == '' {
    exec{ "psql -h ${host} --username=${username} ${database} -c \"${sql}\" && /bin/sleep 5":
      path      => $::path,
      timeout   => 600,
      unless    => "psql -h ${host} -U ${username} ${database} -c ${sqlcheck}",
      logoutput => true,
    }
  } else {
    exec{ "psql -h ${host} --username=${username} ${database} -c \"${sql}\" && /bin/sleep 5":
      environment => "PGPASSWORD=${password}",
      path        => $::path,
      timeout     => 600,
      unless      => "psql -h ${host} -U ${username} ${database} -c ${sqlcheck}",
      logoutput   => true,
    }
  }
}
