# == Define: postgres::config
#
# Configuration of postgres instance
define postgres::config (
  $listen  = 'localhost',
  $version = '9.0'
) {
  file {"/var/lib/pgsql/${version}/data/postgresql.conf":
    content => template('postgres/postgresql.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    notify  => Service['postgresql'],
    # require => File['/var/lib/pgsql/.order'],
    require => Exec['InitDB'],
  }
}
