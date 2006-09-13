class HomeController < ApplicationController
  
  session :on
  
  def index
    flash[:message] = 'Flash message from customized controller'
  end

end
