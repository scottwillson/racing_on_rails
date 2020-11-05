# frozen_string_literal: true

class PeopleController < ApplicationController
  before_action :require_current_person, only: %i[edit update card]
  before_action :assign_person, only: %i[edit update card]
  before_action :require_same_person_or_administrator_or_editor, only: %i[edit update card]

  def index
    respond_to do |format|
      format.html { find_people }
      format.js { find_people }
      format.xml { render xml: find_people.to_xml(only: %i[id first_name last_name]) }
      format.json { render json: find_people.as_json(only: %i[id first_name last_name name city], methods: [:team_name]) }
    end
  end

  def list
    people_list = []
    Person.name_like(params["name"]).each { |person| people_list.push("label" => person.name, "id" => person.id) }
    render json: people_list
  end

  def account
    flash.keep
    person = (params[:id] && Person.find(params[:id])) || current_person
    if person
      redirect_to edit_person_path(person)
    else
      session[:return_to] = "/account"
      redirect_to new_person_session_url
    end
  end

  def update
    if @person.update(person_params)
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
                  filename: "card.pdf",
                  type: "application/pdf"
      end
    end
  end

  # Page to create a new login
  def new_login
    if current_person&.login.present?
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
        ActiveSupport::Notifications.instrument "invalid_token.login.people.racing_on_rails", token: params[:id]
        return redirect_to(login_path)
      end

      if @person.login.present?
        flash[:notice] = "You already have a login of '#{@person.login}'. <a href=\"/password_resets/new\" class=\"obvious\">Forgot your password?</a>"
        ActiveSupport::Notifications.instrument "duplicate_login.login.people.racing_on_rails", login: @person.login
        return redirect_to(login_path)
      end

      if @person.update(person_params)
        @person.reset_perishable_token!
        ActiveSupport::Notifications.instrument "create_for_existing_person.login.people.racing_on_rails", login: person_params[:login]
        flash[:notice] = "Created your new login"
        begin
          PersonMailer.new_login_confirmation(@person).deliver_now
        rescue StandardError
          nil
        end
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
      @person = Person.name_like(person_params[:name]).detect do |person|
        person.license == license ||
          person.race_numbers.any? { |num| num.value == license && (num.year == RacingAssociation.current.effective_year || num.year == RacingAssociation.current.effective_year - 1) }
      end

      if @person&.login.present?
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

    @person.errors.add :password, "can't be blank" if person_params[:password].blank?

    @person.errors.add :email, "can't be blank" if person_params[:email].blank?

    @person.errors.add :email, "must been email address" if person_params[:email].blank?

    @person.errors.add :login, "can't be blank" if person_params[:login].blank?

    @person.errors.add :license, "should only be numbers" if person_params[:license].present? && person_params[:license].strip[/\D+/]

    if person_params[:name].present? && person_params[:name].strip[/^\d+$/]
      @person.errors.add :name, "is a number. Did you accidently type your license in the name field?"
    end

    return render(:new_login) if @person.errors.any?

    @person.updater = @person
    if @person.update(person_params)
      flash[:notice] = "Created your new login"
      ActiveSupport::Notifications.instrument "create_person.login.people.racing_on_rails", login: person_params[:login]
      PersonSession.create @person
      begin
        PersonMailer.new_login_confirmation(@person).deliver_now
      rescue StandardError
        nil
      end
      if @return_to.present?
        uri = URI.parse(@return_to)
        redirect_to URI::Generic.build(path: uri.path, query: uri.query).to_s
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
    @people = if @name.present?
                if params[:per_page]
                  Person.name_like(@name[0, 32]).paginate(page: page, per_page: params[:per_page])
                else
                  Person.name_like(@name[0, 32]).page(page)
                end
              else
                Person.none
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
      :cell_fax,
      :city,
      :club_name,
      :country_code,
      :date_of_birth,
      :dh_category,
      :email,
      :emergency_contact,
      :emergency_contact_phone,
      :fabric_road_numbers,
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
      :race_promotion_interest,
      :road_category,
      :state,
      :street,
      :team_id,
      :team_interest,
      :team_name,
      :track_category,
      :velodrome_committee_interest,
      :volunteer_interest,
      :wants_email,
      :wants_mail,
      :work_phone,
      :zip
    )
  end

  def user_for_paper_trail
    (current_person || @person)&.name_or_login
  end
end
