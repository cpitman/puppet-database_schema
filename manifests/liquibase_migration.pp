# == Define database_schema::liquibase_migration
#
# Ensures that a directory of migration scripts are applied to a database.
#
# === Parameters
#
# [*changelog_source*]
#  Require path to a changelog file containing a liquibase changelog. 
#  Supports puppet and file schemas.
# [*db_username*]
#  Required username to use when connecting to database.
# [*db_password*]
#  Required password to use when connecting to database.
# [*jdbc_url*]
#  Required jdbc formatted database connection string.
# [*liquibase_path*]
#  Path to the liquibase executable. Defaults to "/opt/liquibase".
# [*default_schema*]
#  Default schema to apply migrations to.
# [*ensure*]
#  Only supported value is "latest".
# [*timeout*]
#  The maximum time the migration should take in seconds.  This gets passed directly to the migration Exec resource. Defaults to 300.
#
define database_schema::liquibase_migration (
  $changelog_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $liquibase_path = '/opt/liquibase',
  $default_schema = undef,
  $ensure         = latest,
  $timeout        = 300,
){
  validate_integer($timeout)

  $title_hash   = sha1(title)
  $changelog_basename = inline_template('<%= File.basename(@changelog_source) %>')
  $staging_path = "/tmp/liquibase-migration-${title_hash}"
  $changelog_path = "${staging_path}/${changelog_basename}"
  file { $staging_path:
    ensure  => directory
  }
  file { $changelog_path:
    ensure => present,
    source => $changelog_source
  }

  $liquibase_base_command = "liquibase --username='${db_username}' --password='${db_password}' --url='${jdbc_url}' --changeLogFile='${changelog_path}'"

  if $default_schema == undef {
    $flyway_command = $liquibase_base_command
  }
  else {
    $flyway_command = "${liquibase_base_command} --defaultSchemaNAme='${default_schema}'"
  }

  exec { "Migration for ${title}":
    cwd     => $liquibase_path,
    path    => "${liquibase_path}:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
    onlyif  => "${flyway_command} status | grep 'change sets have not been applied'",
    command => "${flyway_command} update",
    timeout => $timeout,
    require => File[$changelog_path],
  }
}
