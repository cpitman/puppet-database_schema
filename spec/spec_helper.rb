require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end