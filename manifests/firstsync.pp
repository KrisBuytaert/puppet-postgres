class postgres::firstsync {
  exec {
    '/usr/bin/ssh-keyscan dupont dupond >> .ssh/known_hosts':
      user    => postgres,
      creates => '/var/lib/pgsql/.ssh/known_hosts',
      require => File['/var/lib/pgsql/.ssh'],
      cwd     => '/var/lib/pgsql',
  }
}
