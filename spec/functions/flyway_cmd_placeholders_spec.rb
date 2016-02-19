require 'spec_helper'
require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

describe 'flyway_cmd_placeholders', :type => :puppet_function do
  context 'with a valid placeholder hash { \'keyABC\' => \'valueXYZ\' }' do
    placeholders    = { 'keyABC' => 'valueXYZ' }
    expected_result = '-placeholders.keyABC=\'valueXYZ\''

    it "should return '#{expected_result}'" do
      should run.with_params(placeholders).and_return(expected_result)
    end
  end

  context 'with a valid placeholder hash { \'keyABC\' => \'valueXYZ\', \'keyFOO\' => \'valueBAR\' }' do
    placeholders    = { 'keyABC' => 'valueXYZ', 'keyFOO' => 'valueBAR' }
    expected_result = '-placeholders.keyABC=\'valueXYZ\' -placeholders.keyFOO=\'valueBAR\''
    it "should return '#{expected_result}'" do
      should run.with_params(placeholders).and_return(expected_result)
    end
  end

  context 'with an empty placeholder hash' do
    it 'should return an empty string' do
      should run.with_params({}).and_return('')
    end
  end
end
