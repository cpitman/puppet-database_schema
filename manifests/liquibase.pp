# == Class database_schema::liquibase
#
# Ensures liquibase is installed from maven or a custom source. No jdbc drivers
# are installed as part of this resource. All required jars must be placed in 
# the lib folder of this installation before ensuring migrations.
# 
# === Parameters
#
# [*ensure*]
#  present or absent
# [*version*]
#  The version of liquibase to install. Must be a version available on maven 
#  central if not installing from source. Defaults to "3.3.2".
# [*source*]
#  Path to a tar.gz archive to install if not installing from maven central.
# [*target_dir*]
#  Directory to install liquibase in. Defaults to "/opt".
# [*manage_java*]
#  If true, ensure java is installed before flyway migrations are ensured.
#  Defaults to true.
#
class database_schema::liquibase (
  $ensure      = present,
  $version     = '3.3.2',
  $source      = undef,
  $target_dir  = '/opt',
  $manage_java = true
) {
  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/liquibase/liquibase-core/${version}/liquibase-core-${version}-bin.tar.gz",
    default => $source
  }

  $dir_ensure = $ensure ? {
    absent  => absent,
    default => directory
  }

  if $ensure == present and $manage_java {
    include ::java
    Class['::java'] -> Database_schema::Liquibase_migration<||>
  }

  file { "${target_dir}/liquibase":
    ensure => $dir_ensure,
    force  => true,
  }

  $archive_metadata = load_module_metadata('archive')

  if $archive_metadata['name'] == 'camptocamp-archive' {
    archive { "liquibase-core-${version}-bin":
      ensure   => $ensure,
      url      => $real_source,
      target   => "${target_dir}/liquibase",
      root_dir => 'liquibase',
      checksum => false,
    }
  } elsif $archive_metadata['name'] == 'puppet-archive' {
    archive { "/tmp/liquibase-core-${version}-bin.tar.gz":
      ensure       => $ensure,
      extract      => true,
      extract_path => "${target_dir}/liquibase",
      source       => $real_source,
      creates      => "${target_dir}/liquibase/liquibase.jar",
      cleanup      => true,
    }
  } else {
    fail("database_schema depends on puppet-archive or camptocamp-archive")
  }

  Class['database_schema::liquibase'] -> Database_schema::Liquibase_migration<||>
}
