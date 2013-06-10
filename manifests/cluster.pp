# == Define: postgres::cluster
#
# Creation of a postgres cluster
define postgres::cluster (
  $other_node_ip,
  $listen               = 'localhost',
  $max_connections      = '200',
  $shared_buffers       = '4096MB',
  $work_mem             = '4096MB',
  $effective_cache_size = '10024MB',
  $version              = '9.0'
){
  file {"/var/lib/pgsql/${version}/data/postgresql.conf-master":
    content => template('postgres/postgresql.conf-master.erb'),
    owner   => postgres,
    group   => postgres,
  }
  file {"/var/lib/pgsql/${version}/data/postgresql.conf-slave":
    content => template('postgres/postgresql.conf-slave.erb'),
    owner   => postgres,
    group   => postgres,
  }
  file {"/var/lib/pgsql/${version}/data/recovery.conf-slave":
    content => template('postgres/recovery.conf.erb'),
    owner   => postgres,
    group   => postgres,
  }
}

