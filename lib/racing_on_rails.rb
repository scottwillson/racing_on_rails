$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'racing_on_rails/column'
require 'racing_on_rails/grid'
require 'racing_on_rails/grid_file'
require 'racing_on_rails/association'

require 'racing_on_rails/schedule/schedule'
require 'racing_on_rails/schedule/day'
require 'racing_on_rails/schedule/month'
require 'racing_on_rails/schedule/week'

include RacingOnRails
include RacingOnRails::Schedule