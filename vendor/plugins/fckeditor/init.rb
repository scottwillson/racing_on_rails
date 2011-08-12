$:.unshift "#{File.dirname(__FILE__)}/lib"

# Include hook code here
require 'fckeditor'
require 'fckeditor_version'
require 'fckeditor_file_utils'

FckeditorFileUtils.check_and_install

# make plugin controller available to app
config.autoload_paths += %W(#{Fckeditor::PLUGIN_CONTROLLER_PATH} #{Fckeditor::PLUGIN_HELPER_PATH})

ActionView::Base.send(:include, Fckeditor::Helper)

# require the controller
require 'fckeditor_controller'
