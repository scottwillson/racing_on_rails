module Admin
  # Show Schedule, add and edit Events, edit Results for Events. Promoters can view and edit their own events. Promoters can edit
  # fewer fields than administrators.
  class EventsController < Admin::AdminController
    before_filter :assign_event, only: [ :edit, :update ]
    before_filter :require_administrator_or_promoter, only: [ :edit, :update ]
    before_filter :require_administrator, except: [ :edit, :update ]
    before_filter :assign_disciplines, only: [ :new, :create, :edit, :update ]

    # schedule calendar  with links to admin Event pages
    # === Params
    # * year: (optional) defaults to current year
    # === Assigns
    # * schedule
    # * year
    def index
      @competitions = Event.where("type in (?)", Competition::TYPES).year(@year)
      @schedule = Schedule::Schedule.new(@year, events_for_year(@year))
    end

    # Show results for Event
    # === Params
    # * id: SingleDayEvent id
    # === Assigns
    # * event
    # * disciplines: List of all Disciplines + blank
    def edit
      if params['promoter_id'].present? && current_person.administrator?
        @event.promoter = Person.find(params['promoter_id'])
      end
    end

    # Show page to create new Event
    # === Params
    # * year: optional
    # === Assigns
    # * event: Unsaved SingleDayEvent
    def new
      assign_new_event

      respond_to do |format|
        format.html { render :edit }
        format.js { render(:update) { |page| page.redirect_to(action: :new, event: event_params) } }
      end
    end

    # Create new SingleDayEvent
    # === Params
    # * event: Attributes Hash for new event
    # === Assigns
    # * event: Unsaved SingleDayEvent
    # === Flash
    # * warn
    def create
      assign_new_event
      if @event.save
        expire_cache
        flash[:notice] = "Created #{@event.name}"
        redirect_to edit_admin_event_path(@event)
      else
        flash[:warn] = @event.errors.full_messages.join
        render :edit
      end
    end

    # Create new MultiDayEvent from 'prototype' SingleDayEvent
    # === Params
    # * id: SingleDayEvent
    # === Flash
    # * warn
    def create_from_children
      single_day_event = Event.find(params[:id])
      new_parent = MultiDayEvent.create_from_children(single_day_event.multi_day_event_children_with_no_parent)
      expire_cache
      redirect_to(action: :edit, id: new_parent.to_param)
    end

    # Update existing Event
    # === Params
    # * id
    # * event: Attributes Hash
    # === Assigns
    # * event: Unsaved Event
    # === Flash
    # * warn
    def update
      @event = Event.find(params[:id])

      event_type = params[:event].try(:[], :type)
      if event_type && Event::TYPES.include?(event_type) && @event.type != event_type
        # Rails 3 and strong parameters don't play nice here
        @event.update_column :type, event_type
        @event = Event.find(params[:id])
      end

      if @event.update_attributes(event_params)
        flash[:notice] = "Updated #{@event.name}"
        expire_cache
        redirect_to edit_admin_event_path(@event)
      else
        render :edit
      end
    end

    def update_attribute
      respond_to do |format|
        format.js {
          @event = Event.find(params[:id])
          @event.update_attributes! params[:name] => params[:value]
          expire_cache
          render plain: @event.send(params[:name])
        }
      end
    end

    # Upload results from Excel spreadsheet.
    # Expects column headers in first row
    # Expects Race names in first column before set of results:
    # Senior Women Category 3
    # | 1 | Leitheiser | Ann | HFV |
    # === Params
    # * results_file
    # * id: Event ID
    # === Flash
    # * warn: List invalid columns
    # * notice
    def upload
      uploaded_file = params[:results_file]

      path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
      File.open(path, "wb") do |f|
        f.print(uploaded_file.read)
      end

      temp_file = File.new(path)
      @event = Event.find(params[:id])

      results_file = Results::ResultsFile.new(temp_file, @event)

      begin
        results_file.import
      rescue Ole::Storage::FormatError
        flash[:warn] = "Could not read results file. Try re-saving it in 'Excel 97-2004 Workbook format'"
        assign_disciplines
        return render(:edit)
      end

      expire_cache
      FileUtils.rm temp_file rescue nil

      flash[:notice] = "Imported #{uploaded_file.original_filename}. "
      unless results_file.custom_columns.empty?
        flash[:notice] = flash[:notice] + "Found custom columns: #{results_file.custom_columns.map(&:humanize).join(", ")}. "
        flash[:notice] = flash[:notice] + "(If import file is USAC format, you should expect errors on Organization, Event Year, Event #, Race Date and Discipline.)" if RacingAssociation.current.usac_results_format?
      end

      if results_file.import_warnings.present?
        flash[:notice] = flash[:notice] + "Import warnings: "
        results_file.import_warnings.each do |warning|
          flash[:notice] = flash[:notice] + warning.to_s + " "
        end
      end
      redirect_to(edit_admin_event_path(@event))
    end

    # Upload new Excel Schedule
    # See Schedule::Schedule.import for details
    # Redirects to schedule index if successful
    # === Params
    # * schedule_file
    # === Flash
    # * notice
    # * warn
    def upload_schedule
      uploaded_file = params[:schedule_file]
      path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
      File.open(path, "wb") do |f|
        f.print(uploaded_file.read)
      end

      Schedule::Schedule.import(path)
      expire_cache
      flash[:notice] = "Uploaded schedule from #{uploaded_file.original_filename}"

      redirect_to(admin_events_path)
    end

    # Permanently destroy Event
    # === Params
    # * id
    # === Assigns
    # * event: if Event could not be deleted
    # === Flash
    # * notice
    def destroy
      @event = Event.find(params[:id])
      if @event.destroy
        expire_cache
        respond_to do |format|
          format.html {
            flash[:notice] = "Deleted #{@event.name}"
            if @event.parent
              redirect_to(edit_admin_event_path(@event.parent))
            else
              redirect_to(admin_events_path(year: @event.date.year))
            end
          }
          format.js
        end
      else
        respond_to do |format|
          format.html {
            flash[:notice] = "Could not delete #{@event.name}: #{@event.errors.full_messages.join}"
            redirect_to(admin_events_path(year: @event.date.year))
          }
          format.js { render "destroy_error" }
        end
      end
    end

    def destroy_races
      respond_to do |format|
        format.js {
          @event = Event.find(params[:id])
          # Remember races for view
          @races = @event.races.dup
          @combined_results = @event.combined_results
          @event.destroy_races
          @races = @races.reject { |race| Race.exists?(race.id) }
          expire_cache
        }
      end
    end

    def set_parent
      child = Event.find(params[:child_id])
      parent = Event.find(params[:parent_id])
      child.parent = parent
      child.save!
      redirect_to(edit_admin_event_path(child))
    end

    # Add missing child Events to this Event (their parent)
    def add_children
      parent = Event.find(params[:parent_id])
      parent.missing_children.each do |child|
        child.parent = parent
        child.save!
      end
      redirect_to(edit_admin_event_path(parent))
    end

    protected

    def assign_disciplines
      @disciplines = Discipline.names
    end

    def assign_event
      @event = Event.find(params[:id])
    end

    def assign_new_event
      if params[:event].nil?
        @event = SingleDayEvent.new
        return true
      end

      _params = event_params.dup
      event_type = params[:event][:type]
      if event_type.blank?
        if  _params[:parent_id].present?
          event_type = "Event"
        else
          event_type = "SingleDayEvent"
        end
      end

      unless Event::TYPES.include?(event_type)
        raise "Unknown event type: #{event_type}"
      end

      @event = eval(event_type).new(_params)
    end

    def assign_current_admin_tab
      @current_admin_tab = "Schedule"
    end

    def events_for_year(year)
      single_day_events = SingleDayEvent.year(year)
      childless_multi_day_events = MultiDayEvent.where("id not in (?)", single_day_events.map(&:parent_id).compact).year(year)
      single_day_events + childless_multi_day_events
    end

    private

    def event_params
      _params = params_without_mobile.require(:event).permit(
        :additional_race_price,
        :all_events_discount,
        :atra_points_series,
        :auto_combined_results,
        :bar_points,
        :beginner_friendly,
        :cancelled,
        :chief_referee,
        :city,
        :created_at,
        :custom_suggestion,
        :date,
        :discipline,
        :email,
        :end_date,
        :field_limit,
        :first_aid_provider,
        :flyer,
        :flyer_ad_fee,
        :flyer_approved,
        :human_date,
        :human_registration_ends_on,
        :human_registration_ends_at_time,
        :instructional,
        :ironman,
        :membership_required,
        :name,
        :notes,
        :number_issuer_id,
        :override_registration_ends_at,
        :parent_id,
        :phone,
        :postponed,
        :post_event_fees,
        :practice,
        :pre_event_fees,
        :price,
        :prize_list,
        :promoter_id,
        :promoter_name,
        :promoter_pays_registration_fee,
        :refunds,
        :refund_policy,
        :region_id,
        :registration,
        :registration_ends_at,
        :registration_link,
        :registration_public,
        :sanctioned_by,
        :sanctioning_org_event_id,
        :state,
        :team_id,
        :team_name,
        :time,
        :type,
        :velodrome_id,
        :website
      )
      _params.delete(:type)
      _params
    end
  end
end
