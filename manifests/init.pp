# Class: postgres
#
# This module manages postgres
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage: see postgres/README.markdown
#
# [Remember: No empty lines between comments and class definition]
class postgres(
  $version       = '9.0',
  $short_version = '90',
  $password      = '',
  $running_ip    = '127.0.0.1',
) {
  # Handle version specified in site.pp (or default to postgresql)
  $postgres_client = "postgresql-client-${version}"
  $postgres_server = "postgresql-${version}"

  case $::operatingsystem {
    debian, ubuntu: {
      class {
        'postgres::debian' :
          version => $version;
      }
    }
    CentOS: {
      class {
        'postgres::centos' :
          version       => $version,
          short_version => $short_version,
      }
    }
    default: {
      package {
        [$postgres_client, $postgres_server]:
          ensure => installed,
      }
    }
  }
}
