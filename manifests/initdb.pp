# == Define: postgres::initdb
#
# Initialize the database with the password password.
define postgres::initdb(
  $version       = '9.0',
  $short_version = '90',
  $password      = ''
) {
  if $password == '' {
    exec {
      'InitDB':
        command => "/bin/chown postgres.postgres /var/lib/pgsql && /bin/su  postgres -c \"/usr/pgsql-${version}/bin/initdb /var/lib/pgsql/${version}/data -E UTF8\"",
        require =>  Package["postgresql${short_version}-server"],
        creates => "/var/lib/pgsql/${version}/data/PG_VERSION",
    }
  } else {
    exec {
      'InitDB':
        command => "/bin/chown postgres.postgres /var/lib/pgsql && echo \"${password}\" > /tmp/ps && /bin/su  postgres -c \"/usr/pgsql-${version}/bin/initdb /var/lib/pgsql/${$version}/data --auth='password' --pwfile=/tmp/ps -E UTF8 \" && rm -rf /tmp/ps",
        require =>  Package["postgresql${short_version}-server"],
        creates => "/var/lib/pgsql/${version}/data/PG_VERSION",
    }
  }
}
