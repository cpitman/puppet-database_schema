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
# [*placeholders*]
#  A hash containing placeholders you want flyway to use. Each key expands to a "-placeholder.KEY='VALUE'" argument to flyway.
# [*baseline_on_migrate*]
#  Whether to automatically call baseline when migrate is executed against a non-empty schema with no metadata table (see baselineOnMigrate flyway docs).
#  Defaults to 'undef'.  When 'undef' the -baselineOnMigrate command option is not passed to flyway and flyway will use its own default or the value in its configuration file (if present).
#  Set to `true` or `false` to explicitly override the setting for this migration.
#
define database_schema::flyway_migration (
  $schema_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $flyway_path         = '/opt/flyway-3.1',
  $target_schemas      = undef,
  $ensure              = latest,
  $placeholders        = {},
  $baseline_on_migrate = undef,
){
  $title_hash   = sha1($title)
  $staging_path = "/tmp/flyway-migration-${title_hash}"
  file { $staging_path:
    ensure  => directory,
    recurse => true,
    source  => $schema_source
  }

  validate_hash($placeholders)
  $placeholders_str = flyway_cmd_placeholders($placeholders)

  if $baseline_on_migrate == undef {
    $baseline_on_migrate_str = undef
  } else {
    validate_bool($baseline_on_migrate)
    $baseline_on_migrate_str = " -baselineOnMigrate=${baseline_on_migrate}"
  }

  $target_version = $ensure ? {latest => '', default => " -target=${ensure}"}
  $flyway_base_command = "flyway -user='${db_username}' -password='${db_password}' -url='${jdbc_url}' ${placeholders_str} -locations='filesystem:${staging_path}'${target_version}${baseline_on_migrate_str}"

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
