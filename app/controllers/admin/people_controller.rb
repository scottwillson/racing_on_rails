module Admin
  # Add, delete, and edit Person information. Also merge.
  class PeopleController < Admin::AdminController
    before_filter :require_current_person
    # Funky permissions filtering here to allow officials and promoters download Excel file
    skip_filter :require_administrator, :only => :index
    before_filter :require_administrator_or_promoter_or_official, :only => :index
    before_filter :remember_event
    layout 'admin/application', :except => [ :card, :cards ]

    include ApplicationHelper
    include ActionView::Helpers::TextHelper
  
    # Search for People by name. This is a 'like' search on the concatenated 
    # first and last name, and aliases. E.g.,:
    # 'son' finds:
    #  * Sonja Red
    #  * Charles Sondheim 
    #  * Cheryl Willson
    #  * Scott Willson
    #  * Jim Andersen (with an 'Jim Anderson' alias)
    # Store previous search in session and cookie as 'person_name'.
    # Limit results to RacingAssociation.current.search_results_limit
    # === Params
    # * name
    # === Assigns
    # * person: Array of People
    def index
      if params['format'] == 'ppl' || params['format'] == 'xls'
        return export
      end
    
      @people = []
      @name = params[:name] || session[:person_name] || cookies[:person_name] || ''
      @name.strip!
      session['person_name'] = @name
      cookies[:person_name] = { :value => @name, :expires => Time.zone.now + 36000 }
      if @name.blank?
        @people = []
      else
        @people = Person.find_all_by_name_like(@name, RacingAssociation.current.search_results_limit)
        @people = @people + Person.find_by_number(@name)
        @people = @people.stable_sort_by(:first_name).stable_sort_by(:last_name)
      end
      if @people.size == RacingAssociation.current.search_results_limit
        flash[:notice] = "First #{RacingAssociation.current.search_results_limit} people"
      end

      @current_year = current_date.year
    end

    # == Params
    # * excel_layout: "scoring_sheet" for fewer columns -- intended for scoring race results. "endicia" for card stickers.
    # * include: "print_cards"
    # * format: "ppl" for FinishLynx scoring
    def export
      date = current_date
      if params['excel_layout'] == 'scoring_sheet'
        file_name = 'scoring_sheet.xls'
      elsif params['include'] == 'print_cards'
        file_name = 'print_cards.xls'
      elsif params['format'] == 'ppl'
        file_name = 'lynx.ppl'
      else
        file_name = "people_#{date.year}_#{date.month}_#{date.day}.#{params['format']}"
      end
      headers['Content-Disposition'] = "filename=\"#{file_name}\""

      @people = Person.find_all_for_export(date, params['include'])
    
      respond_to do |format|
        format.html
        format.ppl
        format.xls {
          if params['excel_layout'] == 'scoring_sheet'
            render 'admin/people/scoring_sheet' 
          elsif params['excel_layout'] == 'endicia'
            render 'admin/people/endicia' 
          end
        }
      end
    end
  
    def new
      @person = Person.new
      @race_numbers = []
      @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
      render :edit
    end
  
    def edit
      @person = Person.find(params[:id])
      @race_numbers = RaceNumber.all( :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
      @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
    end
  
    # Create new Person
    # 
    # Existing RaceNumbers are updated from a Hash:
    # :number => {'race_number_id' => {:value => 'new_value'}}
    #
    # New numbers are created from arrays:
    # :number_value => [...]
    # :discipline_id => [...]
    # :number_issuer_id => [...]
    # :number_year => year (not array)
    # New blank numbers are ignored
    def create
      expire_cache
      @person = Person.create(params[:person])
    
      if params[:number_value]
        params[:number_value].each_with_index do |number_value, index|
          unless number_value.blank?
            race_number = @person.race_numbers.create(
              :discipline_id => params[:discipline_id][index], 
              :number_issuer_id => params[:number_issuer_id][index], 
              :year => params[:number_year],
              :value => number_value
            )
            unless race_number.errors.empty?
              @person.errors.add(:base, race_number.errors.full_messages)
            end
          end
        end
      end
      if @person.errors.empty?
        if @event
          redirect_to(edit_admin_person_path(@person, :event_id => @event.id))
        else
          redirect_to(edit_admin_person_path(@person))
        end
      else
        @race_numbers = RaceNumber.all( :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
        @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
        render :edit
      end
    end
  
    # Update existing Person.
    # 
    # Existing RaceNumbers are updated from a Hash:
    # :number => {'race_number_id' => {:value => 'new_value'}}
    #
    # New numbers are created from arrays:
    # :number_value => [...]
    # :discipline_id => [...]
    # :number_issuer_id => [...]
    # :number_year => year (not array)
    # New blank numbers are ignored
    def update
      begin
        expire_cache
        @person = Person.find(params[:id])
        @person.update_attributes(params[:person])
        if params[:number]
          for number_id in params[:number].keys
            begin
              number = RaceNumber.find(number_id)
              number_params = params[:number][number_id]
              if number.value != params[:number][number_id][:value]
                number_params[:updater] = current_person
                RaceNumber.update(number_id, number_params)
              end
            rescue Exception => e
              logger.warn("#{e} updating RaceNumber #{number_id}")
            end
          end
        end
    
        if params[:number_value]
          params[:number_value].each_with_index do |number_value, index|
            unless number_value.blank?
              race_number = @person.race_numbers.create(
                :discipline_id => params[:discipline_id][index], 
                :number_issuer_id => params[:number_issuer_id][index], 
                :year => params[:number_year],
                :value => number_value,
                :updater => current_person
              )
              unless race_number.errors.empty?
                @person.errors.add(:base, race_number.errors.full_messages)
              end
            end
          end
        end
      rescue ActiveRecord::MultiparameterAssignmentErrors => e
        e.errors.each do |multi_param_error|
          @person.errors.add(multi_param_error.attribute)
        end
      end

      if @person.errors.empty?
        if @event
          return redirect_to(edit_admin_person_path(@person, :event_id => @event.id))
        else
          return redirect_to(edit_admin_person_path(@person))
        end
      end
      @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
      @race_numbers = RaceNumber.all( :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
      render :edit
    end
  
    # Preview contents of new members file from event registration service website like SignMeUp or Active.com.
    def preview_import
      if params[:people_file].blank?
        flash[:warn] = "Choose a file of people to import first"
        return redirect_to(:action => :index) 
      end

      path = "#{Dir.tmpdir}/#{params[:people_file].original_filename}"
      File.open(path, "wb") do |f|
        f.print(params[:people_file].read)
      end

      temp_file = File.new(path)
      @people_file = PeopleFile.new(temp_file)
      if @people_file
        assign_years
        session[:people_file_path] = temp_file.path
      else
        redirect_to :index
      end
    
      render "preview_import"
    end
  
    # See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
    def import
      if params[:commit] == 'Cancel'
        session[:people_file_path] = nil
        redirect_to(:action => 'index')

      elsif params[:commit] == 'Import'
        Duplicate.delete_all
        path = session[:people_file_path]
        if path.blank?
          flash[:warn] = "No import file"
          return redirect_to(admin_people_path)
        end
      
        people_file = PeopleFile.new(File.new(path))
        people_file.import(params[:update_membership], params[:year])
        flash[:notice] = "Imported #{pluralize(people_file.created, 'new person')} and updated #{pluralize(people_file.updated, 'existing person')}"
        session[:people_file_path] = nil
        if people_file.duplicates.empty?
          redirect_to admin_people_path
        else
          flash[:warn] = 'Some names in the import file already exist more than once. Match with an existing person or create a new person with the same name.'
          redirect_to duplicates_admin_people_path
        end
        expire_cache

      else
        raise "Expected 'Import' or 'Cancel'"
      end
    end
  
    # Unresolved duplicates after import
    def duplicates
      @duplicates = Duplicate.all
      @duplicates.sort! do |x, y|
        diff = (x.person.last_name || '') <=> y.person.last_name
        if diff == 0
          (x.person.first_name || '') <=> y.person.first_name
        else
          diff
        end
      end
    end
  
    def resolve_duplicates
      @duplicates = Duplicate.all
      @duplicates.each do |duplicate|
        id = params[duplicate.to_param]
        if id == 'new'
          duplicate.person.save!
        elsif !id.blank?
          person = Person.update(id, duplicate.new_attributes)
          unless person.valid?
            raise ActiveRecord::RecordNotSaved.new(person.errors.full_messages.join(', '))
          end
        end
      end
  
      Duplicate.delete_all
      redirect_to(:action => 'index')
    end
  
    def update_attribute
      respond_to do |format|
        format.js {
          @person = Person.find(params[:id])
          if params[:name] == "name"
            update_name
          else
            @person.send "#{params[:name]}=", params[:value]
            @person.save!
            expire_cache
            render :text => @person.send(params[:name]), :content_type => "text/html"
          end
        }
      end
    end

    # Toggle membership on or off
    def toggle_member
      person = Person.find(params[:id])
      person.toggle! :member
      render :partial => "shared/member", :locals => { :record => person }
    end
  
    def destroy
      @person = Person.find(params[:id])
      if @person.destroy
        flash.notice = "Deleted #{@person.name}"
        redirect_to admin_people_path
        expire_cache
      else
        flash[:warn] = "Could not delete #{@person.name}. #{@person.errors.full_messages.join(". ")}"
        @race_numbers = RaceNumber.all( :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
        @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
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
        @race_numbers = RaceNumber.all(
          :conditions => [ 'person_id=? and year=?', @person.id, @year ], 
          :order => 'number_issuer_id, discipline_id'
        )
      else
        @person = Person.new
        @race_numbers = []
      end
      @years = (2005..(RacingAssociation.current.next_year)).to_a.reverse
      
      respond_to do |format|
        format.js
      end
    end
  
    # Membership card stickers/labels
    def cards
      @people = Person.all( :conditions => ['print_card=?', true], :order => 'last_name, first_name')
      if @people.empty?
        return redirect_to(no_cards_admin_people_path(:format => "html"))
      else
        Person.update_all("print_card=0, membership_card=1", ['id in (?)', @people.collect{|person| person.id}])
      end

      respond_to do |format|
        format.pdf do
          send_data Card.new.to_pdf(@people), 
                    :filename => "cards.pdf", 
                    :type => "application/pdf"
        end
      end
    end
  
    # Single membership card
    def card
      @person = Person.find(params[:id])
      @people = [@person]
      @person.print_card = false
      @person.membership_card = true
      @person.card_printed_at = Time.zone.now
      @person.save!
    
      respond_to do |format|
        format.pdf do
          send_data Card.new.to_pdf(@person), 
                    :filename => "card.pdf", 
                    :type => "application/pdf"
        end
      end
    end
  
    private

    def update_name
      @person = Person.find(params[:id])
      @person.name = params[:value]

      @other_people = @person.people_with_same_name
      if @other_people.empty?
        @person.save
        expire_cache
        render :text => @person.name, :content_type => "text/html"
      else
        render "merge_confirm"
      end
    end
  
    def assign_years
      date = current_date
      if date.month == 12
        @year = date.year + 1
      else
        @year = date.year
      end
      @years = [ date.year, date.year + 1 ]
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
  end
end
