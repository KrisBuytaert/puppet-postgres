# == Class: postgres::firstsync
#
# This class initializes the first sync of postgres
class postgres::firstsync (
  $version    = '9.0',
  $remotehost = undef,
  $password   = undef
) {
  Exec{logoutput => true}
  exec {
    'sync-ssh-keys':
      command => "/usr/bin/ssh-keyscan ${remotehost} >> .ssh/known_hosts",
      user    => postgres,
      creates => '/var/lib/pgsql/.ssh/known_hosts',
      require => File['/var/lib/pgsql/.ssh'],
      cwd     => '/var/lib/pgsql',
  }
  exec {
    'psql_start_backup':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "psql -h ${remotehost} -c \"SELECT pg_start_backup('label', true)\"",
      environment => "PGPASSWORD=${password}",
      user        => 'postgres',
      creates     => "/var/lib/pgsql/${version}/data/PG_VERSION",
      notify      => Exec['psql_sync'],
      require     => Exec['sync-ssh-keys'],
      tries       => 3,
      try_sleep   => 8,

  }
  exec {
    'psql_sync':
      command     => "rsync -a ${remotehost}:/var/lib/pgsql/${version}/data /var/lib/pgsql/${version} --exclude postmaster.pid --exclude '*-master' --exclude '*-slave'",
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      user        => 'postgres',
      refreshonly => true,
      notify      => Exec['psql_stop_backup'],
  }
  exec {
    'psql_stop_backup':
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "psql -h ${remotehost} -c \"SELECT pg_stop_backup()\" &",
      environment => "PGPASSWORD=${password}",
      user        => 'postgres',
      refreshonly => true,
  }
}
