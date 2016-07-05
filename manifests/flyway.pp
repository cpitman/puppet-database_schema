# == Class database_schema::flyway
#
# Ensures flyway is installed from maven or a custom source.
# 
# === Parameters
#
# [*ensure*]
#  present or absent
# [*version*]
#  The version of flyway to install. Must be a version available on maven 
#  central, or if installing from source must be the version number 
#  contained in the root folder name of the archive. Defaults to "3.1".
# [*source*]
#  Path to a tar.gz archive to install if not installing from maven central.
# [*target_dir*]
#  Directory to install flyway in. Defaults to "/opt".
# [*manage_java*]
#  If true, ensure java is installed before flyway migrations are ensured.
#  Defaults to true.
#
class database_schema::flyway (
  $ensure      = present,
  $version     = '3.1',
  $source      = undef,
  $target_dir  = '/opt',
  $manage_java = true
) {
  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${version}/flyway-commandline-${version}.tar.gz",
    default => $source
  }

  if $ensure == present and $manage_java {
    include ::java
    Class['::java'] -> Database_schema::Flyway_migration<||>
  }

  $archive_metadata = load_module_metadata('archive')

  if $archive_metadata['name'] == 'camptocamp-archive' {
    archive { "flyway-commandline-${version}":
      ensure   => $ensure,
      url      => $real_source,
      target   => $target_dir,
      root_dir => "flyway-${version}",
      checksum => false,
    }
  } elsif $archive_metadata['name'] == 'puppet-archive' {
    if $ensure == 'absent' {
      file { "${target_dir}/flyway-${version}":
        ensure => 'absent',
        force  => true,
      }
    }
    archive { "/tmp/flyway-commandline-${version}.tar.gz":
      ensure       => $ensure,
      extract      => true,
      extract_path => $target_dir,
      source       => $real_source,
      creates      => "${target_dir}/flyway-${version}",
      cleanup      => true,
    }
  } else {
    fail("database_schema depends on puppet-archive or camptocamp-archive")
  }

  Class['database_schema::flyway'] -> Database_schema::Flyway_migration<||>
}
