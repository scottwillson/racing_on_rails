class PeopleController < ApplicationController
  force_https :except => [ :index, :list, :show ]
  
  before_filter :require_current_person, :only => [ :edit, :update, :card ]
  before_filter :assign_person, :only => [ :edit, :update, :card ]
  before_filter :require_same_person_or_administrator_or_editor, :only => [ :edit, :update, :card ]

  def index
    respond_to do |format|
      format.html { find_people }
      format.js { find_people }
      format.xml { render :xml => find_people.to_xml(:only => [ :id, :first_name, :last_name ]) }
      format.json { render :json => find_people.to_json(:only => [ :id, :first_name, :last_name ]) }
    end
  end

  def list
    people_list = Array.new
    Person.find_all_by_name_like(params['name']).each { |person| people_list.push( { "label" => person.name, "id" => person.id.to_s} ) }
    render :json => people_list
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
    if @person.update_attributes(person_params)
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
      
      if @person.update_attributes(person_params)
        @person.reset_perishable_token!
        flash[:notice] = "Created your new login"
        PersonMailer.new_login_confirmation(@person).deliver rescue nil
        return redirect_to(edit_person_path(@person))
      else
        return render(:new_login)
      end
    end
    
    license = person_params[:license].try(:strip)
    if license.present? && person_params[:name].blank?
      @person = Person.new(person_params)
      @person.errors.add :name, "can't be blank if license is present"
      return render(:new_login)
    end
    
    if license.present?
      @person = Person.find_all_by_name_like(person_params[:name]).detect do |person|
        person.license == license ||
        person.race_numbers.any? { |num| num.value == license && (num.year == RacingAssociation.current.effective_year || num.year == RacingAssociation.current.effective_year - 1) }
      end

      if @person && @person.login.present?
        flash.now[:warn] = "Sorry, there's already a login for number ##{license}. <a href=\"/password_resets/new\" class=\"obvious\">Forgot your password?</a>"
        @person = Person.new(person_params)
        return render(:new_login)
      end
      
      if @person.nil?
        @person = Person.new(person_params)
        @person.errors.add :base, "Didn't match your name and number. Please check your #{RacingAssociation.current.short_name} membership card."
      end
    end
    @person = Person.new if @person.nil?
    @person.attributes = person_params
    
    if person_params[:password].blank?
      @person.errors.add :password, "can't be blank"
    end
    
    if person_params[:email].blank?
      @person.errors.add :email, "can't be blank"
    end
    
    if person_params[:email].blank? || !person_params[:email][Authlogic::Regex.email]
      @person.errors.add :email, "must been email address"
    end
    
    if person_params[:login].blank?
      @person.errors.add :login, "can't be blank"
    end
    
    if person_params[:license].present? && person_params[:license].strip[/\D+/]
      @person.errors.add :license, "should only be numbers"
    end
    
    if person_params[:name].present? && person_params[:name].strip[/^\d+$/]
      @person.errors.add :name, "is a number. Did you accidently type your license in the name field?"
    end

    if @person.errors.any?
      return render(:new_login)
    end
    
    if @person.update_attributes(person_params)
      flash[:notice] = "Created your new login"
      PersonSession.create @person
      PersonMailer.new_login_confirmation(@person).deliver rescue nil
      if @return_to.present?
        uri = URI.parse(@return_to)
        redirect_to URI::Generic.build(:path => uri.path, :query => uri.query).to_s
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

  def person_params
    params_without_mobile.require(:person).permit(
      :billing_city,
      :billing_country_code,
      :billing_first_name,
      :billing_last_name,
      :billing_state,
      :billing_street,
      :billing_zip,
      :bmx_category,
      :ccx_category,
      :ccx_only,
      :cell_fax,
      :city,
      :club_name,
      :country_code,
      :date_of_birth,
      :dh_category,
      :email,
      :emergency_contact,
      :emergency_contact_phone,
      :first_name,
      :gender,
      :home_phone,
      :last_name,
      :license,
      :login,
      :membership_address_is_billing_address,
      :membership_card,
      :member_from,
      :member_to,
      :member_usac_to,
      :mtb_category,
      :name,
      :ncca_club_name,
      :notes,
      :occupation,
      :official,
      :official_interest,
      :password,
      :password_confirmation,
      :race_promotion_interest,
      :road_category,
      :state,
      :street,
      :team_id,
      :team_interest,
      :team_name,
      :track_category,
      :volunteer_interest,
      :wants_email,
      :wants_mail,
      :work_phone,
      :zip
    )
  end
end
