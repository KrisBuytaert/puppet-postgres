Postgres Puppet module.

All bugs produced by Kris Buytaert (and now Kit Plummer too). 

There are two variables that need to be set at the site.pp level:
`$postgres_password = "password"`
This sets the default password for the postgres user and database.
and
`$postgres_version = "84"`
This sets the version of Postgres to be required.

Init the database before you start configuring files as once hba files etc exists in /var/lib/pgsql/data the initial database creation won't work anymore .

    include postgres
    postgres::initdb{ "host": }
    # Current postmaster.ops template has only listen address configurable,  this can offcourse be expanded as needed...
    postgres::config{ "host": listen => "*", }
    postgres::hba { "host":
      allowedrules => [
        "host    DATABASE all    10.0.0.0/32  trust",
      ],
    }
    postgres::enable{ "host": }`

To add a user and password:

`postgres::createuser{"username":passwd => "password",}`

To create a new database:

`postgres::createdb{"newdb":owner=> "username",}`
