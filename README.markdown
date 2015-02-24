database_schema
===============

This module manages the process of applying dtaabase schema migration scripts 
as part of a puppet manifest. The actual migration process is dispatched to a 
database migration tool.

The tools currently supported are:

* Flybase
* Liquibase 

This module can also manage the installation of supported tools.

Examples
--------

The following example ensures flyway is installed and that migrations have been 
applied to a MySql database.

    include ::database_schema::flyway
    
    database_schema::flyway_migration { 'Migrate TestDB':
      db_username   => root,
      db_password   => password,
      jdbc_url      => 'jdbc:mysql://localhost/testdb',
      schema_source => '/vagrant/tests/data/stage1'
    }
    
Limitations
-----------

* `flyway_migration` currently only supports SQL based migrations.
* `liquibase` installs liquibase but not any jdbc drivers. These need to be 
  installed to the lib folder of liquibase for the database in use. 