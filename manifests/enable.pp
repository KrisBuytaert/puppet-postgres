# == Define: postgres::enable
#
# Start the service if not running
define postgres::enable (
  $version = '9.0'
) {
  case $::operatingsystem {
    CentOS: {
      $service_name = "postgresql-${version}"
    }
    default: {
      $service_name = 'postgresql'
    }
  }
  service { 'postgresql':
    ensure    => running,
    name      => $service_name,
    enable    => true,
    hasstatus => true,
    require   => Exec['InitDB'],
  }
}
