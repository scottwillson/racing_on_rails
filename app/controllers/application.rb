# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# 
# Includes Racing on Rails engine for controllers. Shared Racing on Rails controller code is in ApplicationControllerBase
class ApplicationController < ActionController::Base
  include RacingOnRails
  include ApplicationControllerBase
end
