require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.default_facts = {
    :path => '/sbin:/bin:/usr/sbin:/usr/bin:/root/bin'
  }
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
