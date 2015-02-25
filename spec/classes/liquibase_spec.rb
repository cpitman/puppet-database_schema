require 'spec_helper'

describe 'database_schema::liquibase' do
  let(:facts){{:operatingsystem => 'RedHat', :osfamily => 'RedHat'}}
  include_examples :compile
end