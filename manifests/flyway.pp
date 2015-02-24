class database_schema::flyway (
  $ensure     = present,
  $version    = '3.1',
  $source     = undef,
  $target_dir = '/opt'
) {
  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${version}/flyway-commandline-${version}.tar.gz",
    default => $source
  }

  if $ensure == present {
    include ::java
    Class['::java'] -> Database_schema::Flyway_migration<||>
  }
  
  archive { "flyway-commandline-${version}":
    ensure   => $ensure,
    url      => $real_source,
    target   => $target_dir,
    root_dir => "flyway-${version}",
    checksum => false
  }
  
  Class['database_schema::flyway'] -> Database_schema::Flyway_migration<||>
}