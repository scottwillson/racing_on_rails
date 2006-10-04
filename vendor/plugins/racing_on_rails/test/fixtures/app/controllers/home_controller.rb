class HomeController < ApplicationController #:nodoc: all
  
  session :on
  
  def index
    flash[:message] = 'Flash message from customized controller'
  end

end
