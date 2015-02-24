define database_schema::flyway_migration (
  $schema_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $flyway_path         = '/opt/flyway-3.1',
  $target_schemas      = undef,
  $ensure              = latest
){
  $title_hash   = sha1(title)
  $staging_path = "/tmp/flyway-migration-${title_hash}"
  file { $staging_path:
    ensure  => directory,
    recurse => true,
    source  => $schema_source
  }
  
  $flyway_base_command = "flyway -user='${db_username}' -password='${db_password}' -url='${jdbc_url}' -locations='filesystem:${staging_path}'"
  
  if $target_schemas == undef {
    $flyway_command = $flyway_base_command  
  }
  else {
    $joined_schemas = join($target_schemas, ',')
    $flyway_command = "${flyway_base_command} -schemas='${joined_schemas}'" 
  }
  
  exec { "Migration for ${title}":
    cwd     => $flyway_path,
    path    => "$flyway_path:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
    unless  => "${flyway_command} validate",
    command => "${flyway_command} migrate",
    require => File[$staging_path]
  }
}