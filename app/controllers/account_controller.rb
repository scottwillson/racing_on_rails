# User authentication
# See also LoginModule
class AccountController < ApplicationController
  layout 'application'

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
  def login
  end
  
  def authenticate
    @user = User.authenticate(params[:email], params[:user_password])
    if @user
      session[:user_id] = @user.id
      if @user.has_role?("Administrator")
        redirect_back_or_default(admin_home_path)
      else
        redirect_back_or_default('/')
      end
    else
      flash[:warn]  = "Cannot login with that email address or password"
      @email = params[:email]
      @user_password = params[:user_password]
      render :action => "login"
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
    session[:user_id] = nil
    redirect_to '/'
  end
end
