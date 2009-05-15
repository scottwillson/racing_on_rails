#!/usr/bin/env ruby

# The git clone is a bit of a hack, but seems like the easiest solution to pulling in different projects
#
# Intentionally doing git clone and rake cruise in separate processes to ensure that all of the
# local overrides are loaded by Rake.

project_name = ARGV.first
project.source_control.branch = "montanabranch"

case project_name
when "racing_on_rails", "montanabranch"
  exec "rake cruise"
when "aba", "atra", "obra", "wsba"
  exec "rm -rf local && git clone git@butlerpress.com:#{project_name}.git local && rake cruise"
else
  raise "Don't know how to build project named: '#{project_name}'"
end
