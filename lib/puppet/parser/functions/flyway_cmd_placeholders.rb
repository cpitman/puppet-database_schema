module Puppet::Parser::Functions
  newfunction(:flyway_cmd_placeholders,:type => :rvalue) do |args|
    raise Puppet::ParseError, "flyway_cmd_placeholders argument must be a hash" unless args[0].is_a?(Hash)

    placeholders = Array.new
    args[0].each do |k,v|
      raise Puppet::ParseError, "flyway_cmd_placeholders hash keys must be strings"   unless k.is_a?(String)
      raise Puppet::ParseError, "flyway_cmd_placeholders hash values must be strings" unless v.is_a?(String)
      placeholders << "-placeholders.#{k}='#{v}'"
    end

    output = placeholders.join(' ')
  end
end
