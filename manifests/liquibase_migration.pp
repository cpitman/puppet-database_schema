define database_schema::liquibase_migration (
  $changelog_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $liquibase_path      = '/opt/liquibase',
  $default_schema      = undef,
  $ensure              = latest
){
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
    path    => "$liquibase_path:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
    onlyif  => "${flyway_command} status | grep 'change sets have not been applied'",
    command => "${flyway_command} update",
    require => File[$changelog_path]
  }
}