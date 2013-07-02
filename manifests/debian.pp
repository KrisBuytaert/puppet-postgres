# == Class: postgres::debian
#
# Installation of debian alike packages
class postgres::debian ( $version = '8.4' ) {
  package {
    "postgresql-${version}" :
      ensure => installed;
    "postgresql-client-${version}" :
      ensure => installed;
  }
}
