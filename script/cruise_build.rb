#!/usr/bin/env ruby

project_name = ARGV.first

case project_name
when "racing_on_rails"
  # Nothing else to get
when "atra"
  exec("svn co svn+ssh://butlerpress.com/var/repos/atra/trunk local")
else
  raise "Don't know how to build project named: '#{project_name}'"
end

exec("rake cruise")
