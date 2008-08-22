#!/usr/bin/env ruby

# The svn:externals is a bit of a hack, but seems like the easiest solution to pulling in different projects
#
# Intentionally doing svn co and rake cruise in separate processes to ensure that all of the
# local overrides are loaded by Rake.

project_name = ARGV.first

case project_name
when "racing_on_rails"
  exec("rake cruise")
when "aba", "atra", "obra", "wsba"
  exec(%Q{svn propset "svn:externals" "local svn+ssh://butlerpress.com/var/repos/#{project_name}/trunk" . && rake cruise})
else
  raise "Don't know how to build project named: '#{project_name}'"
end
