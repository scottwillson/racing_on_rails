class PeopleController < ApplicationController
  before_filter :require_person, :only => [ :edit, :update, :card ]
  before_filter :assign_person, :only => [ :edit, :update, :card ]
  before_filter :require_same_person_or_administrator, :only => [ :edit, :update, :card ]

  ssl_required :edit, :update, :card, :new_login, :create_login, :account
  
  def index
    @people = []
    @name = params['name'] || ''
    @name.strip!
    if @name.present?
      @people = Person.find_all_by_name_like(@name)
      @people = @people.paginate(:page => params[:page])
      @name = ''
    end
  end
  
  def account
    person = (params[:id] && Person.find(params[:id])) || current_person
    if person
      redirect_to edit_person_path(person)
    else
      session[:return_to] = "/account"
      redirect_to new_person_session_path
    end
  end
  
  def update
    if @person.update_attributes(params[:person])
      redirect_to edit_person_path(@person)
    else
      render :edit
    end
  end

  def card
    # Workaround Rails 2.3 bug. Unit tests can't find correct template.
    render(:template => "admin/people/card.pdf.pdf_writer")
  end
  
  def new_login
    if current_person
      flash[:notice] = "You already have a login. You can your login or password on this page."
      return redirect_to(edit_person_path(current_person))
    end
    flash[:notice] = nil
    @person = Person.new
    @return_to = params[:return_to]
  end

  def create_login
    @return_to = params[:return_to]
    
    if (params[:person][:license].blank? && params[:person][:name].present?)
      @person = Person.new(params[:person])
      @person.errors.add :license, "can't be blank if name is present"
      return render(:new_login)
    end
    
    if (params[:person][:license].present? && params[:person][:name].blank?)
      @person = Person.new(params[:person])
      @person.errors.add :name, "can't be blank if license is present"
      return render(:new_login)
    end
    
    if params[:person][:license].present? && params[:person][:name].present?
      @person = Person.find_all_by_name_like(params[:person][:name]).detect { |person|
        person.license == params[:person][:license].strip
      }

      if @person && @person.login.present?
        flash.now[:warn] = "Sorry, there's already a login for license ##{params[:person][:license]}. <a href=\"/password_resets/new\" class=\"obvious\">Forgot your password?</a>"
        return render(:new_login)
      end
      
      if @person.nil?
        @person = Person.new
        @person.errors.add_to_base "Didn't match your name and license number. Please check your #{ASSOCIATION.short_name} membership card."
      end
    end
    @person = Person.new if @person.nil?
    @person.attributes = params[:person]
    
    if params[:person][:password].blank?
      @person.errors.add :password, "can't be blank"
    end
    
    if params[:person][:email].blank?
      @person.errors.add :email, "can't be blank"
    end
    
    unless params[:person][:email][Authlogic::Regex.email]
      @person.errors.add :email, "must been email address"
    end
    
    if params[:person][:login].blank?
      @person.errors.add :login, "can't be blank"
    end
    
    if @person.errors.any?
      return render(:new_login)
    end
    
    if @person.update_attributes(params[:person])
      flash[:notice] = "Created your new login"
      PersonMailer.deliver_new_login_confirmation(@person) rescue nil
      if @return_to.present?
        redirect_to @return_to
        session[:return_to] = nil
      else
        redirect_to edit_person_path(@person)
      end
    else
      render :new_login
    end
  end
end
