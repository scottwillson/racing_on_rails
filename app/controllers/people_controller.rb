class PeopleController < ApplicationController
  include Api::People
  
  before_filter :require_current_person, :only => [ :edit, :update, :card ]
  before_filter :assign_person, :only => [ :edit, :update, :card ]
  before_filter :require_same_person_or_administrator_or_editor, :only => [ :edit, :update, :card ]

  ssl_required :edit, :update, :card, :new_login, :create_login, :account
  ssl_allowed :index
  
  # Search for People
  # == Params
  # * name: case-insensitive SQL 'like' query
  # * license: JSON and XML only
  # * page: JSON and XML only
  #
  # == Returns
  # JSON and XML results are paginated with a page size of 10
  # :id, :first_name, :last_name, :date_of_birth, :license, :gender
  # :aliases      => :alias, :name
  # :team         => :name, :city, :state, :website
  # :race_numbers => :value, :year
  # :discipline   => :only => :name
  #
  # See source code of Api::People and Api::Base
  def index
    respond_to do |format|
      format.html { find_people }
      format.js { find_people }
      format.xml { render :xml => people_as_xml }
      format.json { render :json => people_as_json }
    end
  end

  def list
    people_list = Array.new
    Person.find_all_by_name_like(params['term']).each { |person| people_list.push( { "label" => person.name, "id" => person.id.to_s} ) }
    render :json => people_list
  end

  def show
    respond_to do |format|
      format.xml { render :xml => person_as_xml }
      format.json { render :json => person_as_json }
    end
  end

  def account
    flash.keep
    person = (params[:id] && Person.find(params[:id])) || current_person
    if person
      redirect_to edit_person_path(person)
    else
      session[:return_to] = "/account"
      redirect_to new_person_session_url(secure_redirect_options)
    end
  end
  
  def update
    if @person.update_attributes(params[:person])
      flash[:notice] = "Updated #{@person.name}"
      redirect_to edit_person_path(@person)
    else
      render :edit
    end
  end
  
  # Print membership card
  def card
    respond_to do |format|
      format.pdf do
        send_data Card.new.to_pdf(@person), 
                  :filename => "card.pdf", 
                  :type => "application/pdf"
      end
    end
  end
  
  # Page to create a new login
  def new_login
    if current_person && current_person.login.present?
      flash[:notice] = "You already have a login. You can change your login or password here on your account page."
      return redirect_to(edit_person_path(current_person))
    end
    flash.discard(:notice)
    if params[:id].present?
      @person = Person.find_using_perishable_token(params[:id])
      if @person.nil?
        flash[:notice] = "Can't create new login from that link. Please email #{RacingAssociation.current.email}."
        return redirect_to(login_path)
      end
    else
      @person = Person.new
    end
    @return_to = params[:return_to]
  end

  def create_login
    @return_to = params[:return_to]

    if params[:id].present?
      @person = Person.find_using_perishable_token(params[:id])
      if @person.nil?
        flash[:notice] = "Can't create new login from that link. Please email #{RacingAssociation.current.email}."
        return redirect_to(login_path)
      end
      if @person.login.present?
        flash[:notice] = "You already have a login of '#{@person.login}'. <a href=\"/password_resets/new\" class=\"obvious\">Forgot your password?</a>"
        return redirect_to(login_path)
      end
      
      if @person.update_attributes(params[:person])
        @person.reset_perishable_token!
        flash[:notice] = "Created your new login"
        PersonMailer.new_login_confirmation(@person).deliver rescue nil
        return redirect_to(edit_person_path(@person))
      else
        return render(:new_login)
      end
    end
    
    license = params[:person][:license].try(:strip)
    if license.present? && params[:person][:name].blank?
      @person = Person.new(params[:person])
      @person.errors.add :name, "can't be blank if license is present"
      return render(:new_login)
    end
    
    if license.present?
      @person = Person.find_all_by_name_like(params[:person][:name]).detect do |person|
        person.license == license ||
        person.race_numbers.any? { |num| num.value == license && (num.year == RacingAssociation.current.effective_year || num.year == RacingAssociation.current.effective_year - 1) }
      end

      if @person && @person.login.present?
        flash.now[:warn] = "Sorry, there's already a login for number ##{license}. <a href=\"/password_resets/new\" class=\"obvious\">Forgot your password?</a>"
        @person = Person.new(params[:person])
        return render(:new_login)
      end
      
      if @person.nil?
        @person = Person.new(params[:person])
        @person.errors.add :base, "Didn't match your name and number. Please check your #{RacingAssociation.current.short_name} membership card."
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
    
    if params[:person][:email].blank? || !params[:person][:email][Authlogic::Regex.email]
      @person.errors.add :email, "must been email address"
    end
    
    if params[:person][:login].blank?
      @person.errors.add :login, "can't be blank"
    end
    
    if params[:person][:license].present? && params[:person][:license].strip[/\D+/]
      @person.errors.add :license, "should only be numbers"
    end
    
    if params[:person][:name].present? && params[:person][:name].strip[/^\d+$/]
      @person.errors.add :name, "is a number. Did you accidently type your license in the name field?"
    end

    if @person.errors.any?
      return render(:new_login)
    end
    
    if @person.update_attributes(params[:person])
      flash[:notice] = "Created your new login"
      PersonSession.create @person
      PersonMailer.new_login_confirmation(@person).deliver rescue nil
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

  
  private

  def find_people
    @name = params[:name].try(:strip)
    if @name.present?
      @people = Person.find_all_by_name_like(@name, RacingAssociation.current.search_results_limit, params[:page])
    else
      @people = []
    end
  end
end
