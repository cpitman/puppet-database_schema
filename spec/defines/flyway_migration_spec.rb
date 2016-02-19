require 'spec_helper'

describe 'database_schema::flyway_migration' do
  let(:title){"example db"}
  let(:params){{
    :schema_source => '/some/path',
    :db_username   => 'user',
    :db_password   => 'supersecret',
    :jdbc_url      => 'jdbc:h2:test'
  }}
  include_examples :compile
end