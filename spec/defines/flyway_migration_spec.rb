require 'spec_helper'

describe 'database_schema::liquibase_migration' do
  let(:title){"example db"}
  let(:params){{
    :changelog_source => '/some/path',
    :db_username      => 'user',
    :db_password      => 'supersecret',
    :jdbc_url         => 'jdbc:h2:test'
  }}
  include_examples :compile
end