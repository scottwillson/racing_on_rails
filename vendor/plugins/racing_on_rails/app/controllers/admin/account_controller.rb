class Admin::AccountController < ApplicationController
  
  model :user

  def login
    @user = User.authenticate(params[:username], params[:user_password])
    if @user
      session[:user] = @user
      flash['notice']  = "Login successful"
      redirect_back_or_default :controller => 'schedule', :action => "index"
    else
      if !params[:username].blank? or !params[:user_password].blank? 
        flash.now['notice']  = "Login unsuccessful"
      end
      @login = params[:username]
    end
  end
  
  def logout
    session[:user] = nil
  end
end
