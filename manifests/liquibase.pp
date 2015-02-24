class database_schema::liquibase (
  $ensure     = present,
  $version    = '3.3.2',
  $source     = undef,
  $target_dir = '/opt'
) {
  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/liquibase/liquibase-core/${version}/liquibase-core-${version}-bin.tar.gz",
    default => $source
  }
  
  $dir_ensure = $ensure ? {
    absent  => absent,
    default => directory
  }
  
  if $ensure == present {
    include ::java
    Class['::java'] -> Database_schema::Liquibase_migration<||>
  }
  
  file { "${target_dir}/liquibase":
    ensure => $dir_ensure,
    force  => true
  }
  
  archive { "liquibase-core-${version}-bin":
    ensure   => $ensure,
    url      => $real_source,
    target   => "${target_dir}/liquibase",
    root_dir => 'liquibase',
    checksum => false
  }
  
  Class['database_schema::liquibase'] -> Database_schema::Liquibase_migration<||>
}