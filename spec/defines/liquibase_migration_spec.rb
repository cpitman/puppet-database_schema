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
  describe 'timeout' do
    context 'when not specified' do
      it 'exec has timeout set to 300 seconds' do
        is_expected.to contain_exec('Migration for example db').with_timeout(300)
      end
    end
    context 'when specified' do
      let(:params){{
        :changelog_source => '/some/path',
        :db_username      => 'user',
        :db_password      => 'supersecret',
        :jdbc_url         => 'jdbc:h2:test',
        :timeout          => 3600
      }}
      it 'passes timeout to exec' do
        is_expected.to contain_exec('Migration for example db').with_timeout(3600)
      end
    end
  end
end
