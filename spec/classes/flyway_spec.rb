require 'spec_helper'

describe 'database_schema::flyway' do
  let(:facts){{:operatingsystem => 'RedHat', :osfamily => 'RedHat', :operatingsystemrelease => '7'}}
  include_examples :compile
end
