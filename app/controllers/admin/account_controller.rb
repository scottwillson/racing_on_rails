# User authentication
# See also LoginModule
class Admin::AccountController < ApplicationController
  layout 'admin/application'

  # Show login page and do login. If login succeeds, put an instance of User in session
  # with the key :user. LoginModule uses this User for authorization.
  # 
  # Sessions must be enabled for security to work properly.
  # 
  # This login scheme is insecure unless restricted to https.
  # 
  # === Params
  # * :username
  # * :user_password
  # === Assigns
  # * user: instance of User if authentication succeeds
  # * login: username
  # === Flash
  # * notice 
  # --
  # TODO Separate into two actions
  def login
    @user = User.authenticate(params[:email], params[:user_password])
    if @user
      session[:user] = @user
      redirect_back_or_default(admin_home_path)
    else
      if !params[:email].blank? or !params[:user_password].blank? 
        flash.now[:warn]  = "Login unsuccessful"
      end
      @login = params[:email]
    end
  end
  
  # Send email with password to user
  # 
  # === Params
  # * :email
  # === Flash
  # * notice
  # --
  def forgot
    if request.post? and params[:email] != ""
      user = User.find_by_email(params[:email])
      
      if user
        UserNotifier.deliver_forgot_password(user)
        flash[:info] = "Reminder email sent successfully"
        redirect_to :action => "login"
      else
        flash.now[:warn]  = "Email not found"
      end
    end
  end
  
  # Remove User from session. There is no link to this action, yet.
  def logout
    session[:user] = nil
    redirect_to '/'
  end
end
