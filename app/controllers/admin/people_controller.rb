# Add, delete, and edit Person information. Also merge 
class Admin::PeopleController < ApplicationController
  before_filter :require_administrator, :remember_event
  layout 'admin/application', :except => [:card, :cards, :mailing_labels]
  exempt_from_layout 'xls.erb', 'ppl.erb'

  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  
  in_place_edit_for :person, :team_name
  
  # Search for People by name. This is a 'like' search on the concatenated 
  # first and last name, and aliases. E.g.,:
  # 'son' finds:
  #  * Sonja Red
  #  * Charles Sondheim 
  #  * Cheryl Willson
  #  * Scott Willson
  #  * Jim Andersen (with an 'Jim Anderson' alias)
  # Store previous search in session and cookie as 'person_name'.
  # Limit results to SEARCH_RESULTS_LIMIT
  # === Params
  # * name
  # === Assigns
  # * person: Array of People
  def index
    if params['format'] == 'ppl' || params['format'] == 'xls'
      return export
    end
    
    @people = []
    @name = params['name'] || session['person_name'] || cookies[:person_name] || ''
    @name.strip!
    session['person_name'] = @name
    cookies[:person_name] = {:value => @name, :expires => Time.now + 36000}
    if @name.blank?
      @people = []
    else
      @people = Person.find_all_by_name_like(@name, SEARCH_RESULTS_LIMIT)
      @people = @people + Person.find_by_number(@name)
    end
    if @people.size == SEARCH_RESULTS_LIMIT
      flash[:notice] = "First #{SEARCH_RESULTS_LIMIT} people"
    end

    @current_year = current_date.year

    respond_to do |wants|
      wants.html
      # TODO Optimize JS call. It shouldn't consider cookie and should pull back only nine results
      wants.js
    end
  end

  def export
    date = current_date
    if params['excel_layout'] == 'scoring_sheet'
      file_name = 'scoring_sheet.xls'
    elsif params['format'] == 'ppl'
      file_name = 'lynx.ppl'
    else
      file_name = "people_#{date.year}_#{date.month}_#{date.day}.#{params['format']}"
    end
    headers['Content-Disposition'] = "filename=\"#{file_name}\""

    @people = Person.find_all_for_export(date, params['include'] == 'members_only')
    
    respond_to do |format|
      format.html
      format.ppl
      format.xls {render :template => 'admin/people/scoring_sheet.xls.erb' if params['excel_layout'] == 'scoring_sheet'}
    end
  end
  
  def new
    @year = current_date.year
    @person = Person.new(:member_from => Date.new(@year))
    @race_numbers = []
    @years = (2005..(@year + 1)).to_a.reverse
    render(:action => "edit")
  end
  
  def edit
    @person = Person.find(params[:id])
    @year = current_date.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
    @years = (2005..(@year + 1)).to_a.reverse
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
    params[:person][:created_by] = current_person
    @person = Person.create(params[:person])
    
    if params[:number_value]
      params[:number_value].each_with_index do |number_value, index|
        unless number_value.blank?
          race_number = @person.race_numbers.create(
            :discipline_id => params[:discipline_id][index], 
            :number_issuer_id => params[:number_issuer_id][index], 
            :year => params[:number_year],
            :value => number_value,
            :updated_by => current_person.name
          )
          unless race_number.errors.empty?
            @person.errors.add_to_base(race_number.errors.full_messages)
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
      render(:action => :edit)
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
      params[:person][:updated_by] = current_person.name
      @person.update_attributes(params[:person])
      if params[:number]
        for number_id in params[:number].keys
          begin
            number = RaceNumber.find(number_id)
            number_params = params[:number][number_id]
            if number.value != params[:number][number_id][:value]
              number_params[:updated_by] = current_person.name
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
              :updated_by => current_person.name
            )
            unless race_number.errors.empty?
              @person.errors.add_to_base(race_number.errors.full_messages)
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
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    @year = params[:year] || Date.today.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
    render(:template => 'admin/people/edit')
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
      redirect_to(:action => :index)
    end
    
    render("preview_import", :layout => "admin/people/preview_import")
  end
  
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
        redirect_to(:action => 'index')
      else
        flash[:warn] = 'Some names in the import file already exist more than once. Match with an existing person or create a new person with the same name.'
        redirect_to(:action => 'duplicates')
      end
      expire_cache

    else
      raise("Expected 'Import' or 'Cancel'")
    end
  end
  
  def duplicates
    @duplicates = Duplicate.find(:all)
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
    @duplicates = Duplicate.find(:all)
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

  # Inline update. Merge with existing Person if names match
  def set_person_name
    @person = Person.find(params[:id])
    new_name = params[:value]
    original_name = @person.name
    @person.name = new_name

    people_with_same_name = @person.people_with_same_name
    unless people_with_same_name.empty?
      return merge?(original_name, people_with_same_name, @person)
    end
    
    @person.update_attribute(:name, params[:value])
    expire_cache
    render :update do |page|
      page.replace_html("person_#{@person.id}_name", @person.name)
    end
  end

  def toggle_member
    person = Person.find(params[:id])
    person.toggle!(:member)
    render(:partial => "shared/member", :locals => { :record => person })
  end
  
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    respond_to do |format|
      format.html {redirect_to admin_people_path}
      format.js
    end
    expire_cache
  end

  def merge?(original_name, existing_people, person)
    @person = person
    @existing_people = existing_people
    @original_name = original_name
    render :update do |page| 
      page.replace_html("person_#{@person.id}_row", :partial => 'merge_confirm', :locals => { :person => @person })
    end
  end
  
  def merge
    person_to_merge_id = params[:id].gsub('person_', '')
    @person_to_merge = Person.find(person_to_merge_id)
    @merged_person_name = @person_to_merge.name
    @existing_person = Person.find(params[:target_id])
    @existing_person.merge(@person_to_merge)
    expire_cache
  end
  
  def cancel_in_place_edit
    person_id = params[:id]
    render :update do |page|
      page.replace("person_#{person_id}_row", :partial => "person", :locals => { :person => Person.find(person_id) })
      page.call :restripeTable, :people_table
    end
  end
  
  def number_year_changed
    @year = params[:year] || current_date.year
    if params[:id]
      @person = Person.find(params[:id])
      @race_numbers = RaceNumber.find(:all, :conditions => ['person_id=? and year=?', @person.id, @year], :order => 'number_issuer_id, discipline_id')
    else
      @person = Person.new
      @race_numbers = []
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    render(:partial => '/admin/people/numbers', :locals => {:year => @year.to_i, :years => @years, :person => @person, :race_numbers => @race_numbers})
  end
  
  def new_number
    render :update do |page|
      page.insert_html(
        :before, 'new_number_button_row', 
        :partial => '/admin/people/new_number', 
        :locals => {:discipline_id => Discipline[:road].id})
    end
  end
  
  def destroy_number
    id = params[:id]
    RaceNumber.destroy(id)
    render :update do |page|
      page.visual_effect(:puff, "number_#{id}_row", :duration => 2)
      page.remove("number_#{id}_value")
    end
  end
  
  def destroy_alias
    alias_id = params[:alias_id]
    Alias.destroy(alias_id)
    render :update do |page|
      page.visual_effect(:puff, "alias_#{alias_id}", :duration => 2)
    end
  end
  
  def cards
    @people = Person.find(:all, :conditions => ['print_card=?', true], :order => 'last_name, first_name')
    if @people.empty?
      return redirect_to(no_cards_admin_people_path(:format => "html"))
    else
      Person.update_all("print_card=0", ['id in (?)', @people.collect{|person| person.id}])
    end
    
    # Workaround Rails 2.3 bug. Unit tests can't find correct template.
    render(:template => "admin/people/cards.pdf.pdf_writer")
  end
  
  def card
    @person = Person.find(params[:id])
    @people = [@person]
    @person.print_card = false
    @person.save!
    
    # Workaround Rails 2.3 bug. Unit tests can't find correct template.
    render(:template => "admin/people/card.pdf.pdf_writer")
  end
  
  def mailing_labels
    @people = Person.find(:all, :conditions => ['print_mailing_label=?', true], :order => 'last_name, first_name')
    if @people.empty?
      return redirect_to(no_mailing_labels_admin_people_path(:format => "html"))
    else
      Person.update_all("print_mailing_label=0", ['id in (?)', @people.collect{|person| person.id}])
    end
    
    # Workaround Rails 2.3 bug. Unit tests can't find correct template.
    render(:template => "admin/people/mailing_labels.pdf.pdf_writer")
  end
  
  def rescue_action_in_public(exception)
    headers.delete("Content-Disposition")
    super
  end

  def rescue_action_locally(exception)
    headers.delete("Content-Disposition")
    super
  end
  
  private
  
  def assign_years
    today = current_date
    if today.month == 12
      @year = today.year + 1
    else
      @year = today.year
    end
    @years = [today.year, today.year + 1]
  end

  def current_date
    if params[:date].blank?
      date = Date.today
    else
      date = Date.parse(params[:date])
    end
    max_date_for_current_year = Event.find_max_date_for_current_year
    if max_date_for_current_year && (date > max_date_for_current_year)
      date = Date.new(date.year + 1)
    end
    date
  end
  
  def remember_event
    unless params['event_id'].blank?
      @event = Event.find(params['event_id'])
    end
  end
end
