# == Class: postgres::centos
#
# Installation of centos packages
class postgres::centos(
  $version       = '9.0',
  $short_version = '90'
) {
  package {
    "postgresql${short_version}" :
      ensure  => installed,
      require => Yumrepo['postgresql'];
    "postgresql${short_version}-server" :
      ensure  => installed,
      require => Yumrepo['postgresql'];
  }

  yumrepo {
    'postgresql':
      baseurl     => "http://yum.pgrpms.org/${version}/redhat/rhel-\$releasever-\$basearch",
      gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
      gpgcheck    => 1,
      enabled     => 1,
      require     => File['GPG-Psql-repo'],
  }

  file {
    'GPG-Psql-repo':
      ensure => present,
      path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
      source => "puppet:///modules/postgres/centos/rpm-gpg/RPM-GPG-KEY-PGDG-${version}"
  }

}
