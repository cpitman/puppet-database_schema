include ::database_schema
include ::database_schema::flyway

class { '::mysql::server':
  root_password => password,
  databases     => {
    'testdb'    => {
      ensure    => present
    }
  }
}
->
database_schema::flyway_migration { 'Migrate TestDB':
  db_username   => root,
  db_password   => password,
  jdbc_url      => 'jdbc:mysql://localhost/testdb',
  schema_source => '/vagrant/tests/flyway/data/stage2'
}
