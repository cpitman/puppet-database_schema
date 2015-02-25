include ::database_schema
include ::database_schema::liquibase

include ::wget
wget::fetch { 'MySql JDBC':
  destination =>'/opt/liquibase/lib/mysql.jar',
  source      => 'http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.34/mysql-connector-java-5.1.34.jar',
  require     => Class['::database_schema::liquibase']
}

file { '/tmp/changelog.xml':
  target => '/vagrant/tests/liquibase/data/stage1.xml'
}

class { '::mysql::server':
  root_password => password,
  databases     => {
    'liquibasetestdb' => {
      ensure => present
    }
  }
}
->
database_schema::liquibase_migration { 'Migrate TestDB':
  db_username      => root,
  db_password      => password,
  jdbc_url         => 'jdbc:mysql://localhost/liquibasetestdb',
  changelog_source => '/tmp/changelog.xml',
  require          => [Wget::Fetch['MySql JDBC'], File['/tmp/changelog.xml']]
}
