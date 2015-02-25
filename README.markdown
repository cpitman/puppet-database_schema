database_schema
===============

This module manages the process of applying database schema migration scripts 
as part of a puppet manifest. The actual migration process is dispatched to a 
database migration tool.

The tools currently supported are:

* [Flybase](http://flywaydb.org/)
* [Liquibase](http://www.liquibase.org/index.html) 

This module can also manage the installation of supported tools.

Getting Started
---------------

If you are new to database migration tools and want to get started quickly, 
start with Flyway. Flyway uses straight sql scripts, where the only requirement
is how th files are named (ie "V1__SomeScript.sql", "V2__AnotherScript.sql").
Use this module to install flyway, and you should be migrating databases in no
time at all.

The example below shows how this can be done.

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