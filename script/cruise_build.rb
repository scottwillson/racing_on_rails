#!/usr/bin/env ruby

# Yes, this could be more abstracted, etc. Choosing explicitness for now.
# svn co and rake co need to be in same exec, or cruise just ends build after svn returns
#
# Intentionally doing svn co and rake cruise in separate processes to ensure that all of the
# local overrides are loaded by Rake.

project_name = ARGV.first

case project_name
when "racing_on_rails"
  # Nothing else to get
when "atra"
  exec("svn co svn+ssh://butlerpress.com/var/repos/atra/trunk local && rake cruise")
else
  raise "Don't know how to build project named: '#{project_name}'"
end
