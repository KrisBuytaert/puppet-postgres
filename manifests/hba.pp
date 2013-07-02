# == Define: postgres::hba
#
# Postgres host based authentication
define postgres::hba (
  $allowedrules = undef,
  $version      = '9.0',
  $password     = ''
) {
  file { "/var/lib/pgsql/${version}/data/pg_hba.conf":
    content   => template('postgres/pg_hba.conf.erb'),
    owner     => 'root',
    group     => 'root',
  }
}
