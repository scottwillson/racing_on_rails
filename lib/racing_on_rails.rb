$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'racing_on_rails/column'
require 'racing_on_rails/grid'
require 'racing_on_rails/grid_file'
require 'racing_on_rails/association'

include RacingOnRails
