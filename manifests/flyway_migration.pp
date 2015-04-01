# == Define database_schema::flyway_migration
#
# Ensures that a directory of migration scripts are applied to a database.
#
# === Parameters
#
# [*schema_source*]
#  Require path to a source directory containing sql migration scripts. 
#  Supports puppet and file schemas.
# [*db_username*]
#  Required username to use when connecting to database.
# [*db_password*]
#  Required password to use when connecting to database.
# [*jdbc_url*]
#  Required jdbc formatted database connection string.
# [*flyway_path*]
#  Path to the flyway executable. Defaults to "/opt/flyway-3.1".
# [*target_schemas*]
#  Schemas to apply migrations to, provided as a list of schema names.
# [*ensure*]
#  Version number to migrate up to (see the migrate option "target" in the flyway docs). Defaults to "latest"
#
define database_schema::flyway_migration (
  $schema_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $flyway_path         = '/opt/flyway-3.1',
  $target_schemas      = undef,
  $ensure              = latest
){
  $title_hash   = sha1($title)
  $staging_path = "/tmp/flyway-migration-${title_hash}"
  file { $staging_path:
    ensure  => directory,
    recurse => true,
    source  => $schema_source
  }
  
  $target_version = $ensure ? {latest => '', default => " -target=${ensure}"}
  $flyway_base_command = "flyway -user='${db_username}' -password='${db_password}' -url='${jdbc_url}' -locations='filesystem:${staging_path}'$target_version"
  
  if $target_schemas == undef {
    $flyway_command = $flyway_base_command
  }
  else {
    $joined_schemas = join($target_schemas, ',')
    $flyway_command = "${flyway_base_command} -schemas='${joined_schemas}'"
  }
  
  exec { "Migration for ${title}":
    cwd     => $flyway_path,
    path    => "${flyway_path}:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
    unless  => "${flyway_command} validate",
    command => "${flyway_command} migrate",
    require => File[$staging_path]
  }
}