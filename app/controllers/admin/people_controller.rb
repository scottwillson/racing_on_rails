module Admin
  # Add, delete, and edit Person information. Also merge.
  class PeopleController < Admin::AdminController
    before_filter :require_current_person
    # Funky permissions filtering here to allow officials and promoters download Excel file
    skip_filter :require_administrator, only: :index
    before_filter :require_administrator_or_promoter_or_official, only: :index
    before_filter :remember_event
    layout 'admin/application', except: [ :card, :cards ]

    include ApplicationHelper
    include ActionView::Helpers::TextHelper
    include Admin::People::Cards
    include Admin::People::Import
    include Admin::People::Export

    # Search for People by name. This is a 'like' search on the concatenated
    # first and last name, and aliases. E.g.,:
    # 'son' finds:
    #  * Sonja Red
    #  * Charles Sondheim
    #  * Cheryl Willson
    #  * Scott Willson
    #  * Jim Andersen (with an 'Jim Anderson' alias)
    # Store previous search in session and cookie as 'person_name'.
    # === Params
    # * name
    # === Assigns
    # * person: Array of People
    def index
      if params['format'] == 'ppl' || params['format'] == 'xls'
        return export
      end

      @current_year = current_date.year
      assign_name
      @people = Person.where_name_or_number_like(@name)
      ActiveSupport::Notifications.instrument "search.people.admin.racing_on_rails", name: @name, people_count: @people.count

      respond_to do |format|
        format.html { @people = @people.page(page) }
        format.js   { @people = @people.limit 100 }
      end
    end

    def new
      ActiveSupport::Notifications.instrument "new.people.admin.racing_on_rails"
      @person = Person.new
      assign_race_numbers
      assign_years
      render :edit
    end

    def edit
      @person = Person.includes(:race_numbers).find(params[:id])
      assign_race_numbers
      assign_years
      ActiveSupport::Notifications.instrument "edit.people.admin.racing_on_rails", person_name: @person.name, person_id: params[:id]
    end

    # Create new Person
    #
    # Existing RaceNumbers are updated from a Hash:
    # number: {'race_number_id' => {value: 'new_value'}}
    #
    # New numbers are created from arrays:
    # number_value: [...]
    # discipline_id: [...]
    # number_issuer_id: [...]
    # number_year: year (not array)
    # New blank numbers are ignored
    def create
      expire_cache
      @person = Person.create(person_params)
      ActiveSupport::Notifications.instrument "create.people.admin.racing_on_rails", person_name: @person.name, person_id: @person.id

      if @person.errors.empty?
        if @event
          redirect_to(edit_admin_person_path(@person, event_id: @event.id))
        else
          redirect_to(edit_admin_person_path(@person))
        end
      else
        assign_race_numbers
        assign_years
        render :edit
      end
    end

    # Update existing Person.
    #
    # Existing RaceNumbers are updated from a Hash:
    # number: {'race_number_id' => {value: 'new_value'}}
    #
    # New numbers are created from arrays:
    # number_value: [...]
    # discipline_id: [...]
    # number_issuer_id: [...]
    # number_year: year (not array)
    # New blank numbers are ignored
    def update
      expire_cache
      @person = Person.find(params[:id])
      ActiveSupport::Notifications.instrument "update.people.racing_on_rails", person_id: @person.id, person_name: @person.name

      if @person.update(person_params)
        if @event
          return redirect_to(edit_admin_person_path(@person, event_id: @event.id))
        else
          return redirect_to(edit_admin_person_path(@person))
        end
      end
      assign_years
      assign_race_numbers
      render :edit
    end

    def update_attribute
      respond_to do |format|
        format.js do
          @person = Person.find(params[:id])
          if params[:name] == "name"
            update_name
          else
            @person.update! params[:name] => params[:value]
            expire_cache
            render plain: @person.send(params[:name])
          end
        end
      end
    end

    # Toggle membership on or off
    def toggle_member
      person = Person.find(params[:id])
      person.toggle! :member
      render partial: "shared/member", locals: { record: person }
    end

    def destroy
      @person = Person.find(params[:id])

      ActiveSupport::Notifications.instrument "destroy.people.admin.racing_on_rails", person_id: @person.id

      if @person.destroy
        flash.notice = "Deleted #{@person.name}"
        redirect_to admin_people_path
        expire_cache
      else
        flash[:warn] = "Could not delete #{@person.name}. #{@person.errors.full_messages.join(". ")}"
        assign_race_numbers
        assign_years
        render :edit
      end
    end

    def merge
      @person = Person.find(params[:id])
      @other_person = Person.find(params[:other_person_id])
      @merged = @person.merge(@other_person)
      expire_cache
    end

    def number_year_changed
      if params[:id]
        @person = Person.find(params[:id])
        assign_race_numbers
      else
        @person = Person.new
        @race_numbers = []
      end
      assign_years

      respond_to do |format|
        format.js
      end
    end


    private

    def update_name
      @person = Person.find(params[:id])
      @person.name = params[:value]
      @other_people = @person.people_with_same_name

      ActiveSupport::Notifications.instrument "update_name.people.admin.racing_on_rails", person_id: @person.id, person_name_was: "#{@person.first_name_was} #{@person.last_name_was}", person_name: @person.name, other_people_same_name: @other_people.size

      if @other_people.empty?
        @person.save
        expire_cache
        render plain: @person.name
      else
        render "merge_confirm"
      end
    end

    def assign_race_numbers
      @disciplines = Discipline.numbers
      @number_issuers = NumberIssuer.all
      if @person.race_numbers.none?(&:new_record?)
        @person.race_numbers.build(person_id: @person.id)
      end
    end

    def current_date
      if params[:date].present?
        Date.parse(params[:date])
      else
        RacingAssociation.current.effective_today
      end
    end

    def remember_event
      unless params['event_id'].blank?
        @event = Event.find(params['event_id'])
      end
    end

    def require_administrator_or_promoter
      unless current_person.administrator? ||
        current_person && current_person.promoter? && params[:format] == "xls" && params[:excel_layout] == "scoring_sheet"
        redirect_to unauthorized_path
      end
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "People"
    end


    private

    def assign_name
      @name = params[:name] || session[:person_name] || cookies[:person_name]
      @name = @name.try :strip
      session[:person_name] = @name
      cookies[:person_name] = { value: @name, expires: Time.zone.now + 36000 }
    end

    def assign_years
      @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
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
        :license_expiration_date,
        :license_type,
        :login,
        :member,
        :membership_address_is_billing_address,
        :membership_card,
        :member_from,
        :member_to,
        :member_usac_to,
        :mtb_category,
        :ncca_club_name,
        :notes,
        :occupation,
        :official,
        :official_interest,
        :password,
        :password_confirmation,
        :print_card,
        :race_promotion_interest,
        :road_category,
        :state,
        :status,
        :street,
        :team_id,
        :team_interest,
        :team_name,
        :track_category,
        :volunteer_interest,
        :wants_email,
        :wants_mail,
        :work_phone,
        :zip,
        race_numbers_attributes: [ :discipline_id, :id, :number_issuer_id, :value, :year ]
      )
    end
  end
end
