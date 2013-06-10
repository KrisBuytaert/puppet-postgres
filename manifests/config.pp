# == Define: postgres::config
#
# Configuration of postgres instance
define postgres::config (
  $listen = 'localhost'
) {
  file {'/var/lib/pgsql/data/postgresql.conf':
    content => template('postgres/postgresql.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    notify  => Service['postgresql'],
    # require => File['/var/lib/pgsql/.order'],
    require => Exec['InitDB'],
  }
}
