# Class: postgres::common
#
# Common stuff across postgres class
#
# Parameters:
#
# Actions:
#
# Requires:
#
# [Remember: No empty lines between comments and class definition]
class postgres::common {
  # If you wish, you can uncomment the below to
  # fail the update if postgres_password not set in site.pp
  #case $postgres_password {
  #  "": { fail("postgres_password must be set!")
  #  }
  #}

  #case $postgres_version {
  #  "": { fail("postgres_version must be set!")
  #  }
  #}
}
