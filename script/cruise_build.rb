#!/usr/bin/env ruby

# Yes, this could be more abstracted, etc. Choosing explicitness for now.
# svn co and rake co need to be in same exec, or cruise just ends build after svn returns
#
# Intentionally doing svn co and rake cruise in separate processes to ensure that all of the
# local overrides are loaded by Rake.

project_name = ARGV.first

case project_name
when "racing_on_rails"
  exec("rake cruise")
when "aba"
  exec("svn co svn+ssh://cruise@butlerpress.com/var/repos/aba/trunk ../../local/aba && ln -s ../../local/aba local && rake cruise")
when "atra"
  exec("svn co svn+ssh://cruise@butlerpress.com/var/repos/atra/trunk local && rake cruise")
when "obra"
  exec("svn co svn+ssh://cruise@butlerpress.com/var/repos/obra/trunk local && rake cruise")
when "wsba"
  exec("svn co svn+ssh://cruise@butlerpress.com/var/repos/wsba/trunk local && rake cruise")
else
  raise "Don't know how to build project named: '#{project_name}'"
end
