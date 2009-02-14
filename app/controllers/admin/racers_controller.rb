# Add, delete, and edit Racer information. Also merge 
class Admin::RacersController < ApplicationController
  before_filter :login_required
  layout 'admin/application', :except => [:card, :cards, :mailing_labels]
  exempt_from_layout 'xls.erb', 'ppl.erb'

  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  
  in_place_edit_for :racer, :team_name
  
  # Search for Racers by name. This is a 'like' search on the concatenated 
  # first and last name, and aliases. E.g.,:
  # 'son' finds:
  #  * Sonja Red
  #  * Charles Sondheim 
  #  * Cheryl Willson
  #  * Scott Willson
  #  * Jim Andersen (with an 'Jim Anderson' alias)
  # Store previous search in session and cookie as 'racer_name'.
  # Limit results to ApplicationControllerBase::RESULTS_LIMIT
  # === Params
  # * name
  # === Assigns
  # * racer: Array of Racers
  def index
    if params['format'] == 'ppl' || params['format'] == 'xls'
      return export
    end
    
    @racers = []
    @name = params['name'] || session['racer_name'] || cookies[:racer_name] || ''
    @name.strip!
    session['racer_name'] = @name
    cookies[:racer_name] = {:value => @name, :expires => Time.now + 36000}
    if @name.blank?
      @racers = []
    else
      @racers = Racer.find_all_by_name_like(@name, RESULTS_LIMIT)
      @racers = @racers + Racer.find_by_number(@name)
    end
    if @racers.size == RESULTS_LIMIT
      flash[:notice] = "First #{RESULTS_LIMIT} racers"
    end
    
    @current_year = current_date.year
  end
  
  def export
    date = current_date
    if params['excel_layout'] == 'scoring_sheet'
      file_name = 'scoring_sheet.xls'
    elsif params['format'] == 'ppl'
      file_name = 'lynx.ppl'
    else
      file_name = "racers_#{date.year}_#{date.month}_#{date.day}.#{params['format']}"
    end
    headers['Content-Disposition'] = "filename=\"#{file_name}\""

    @racers = Racer.find_all_for_export(date, params['include'] == 'members_only')
    
    respond_to do |format|
      format.html
      format.ppl
      format.xls {render :template => 'admin/racers/scoring_sheet.xls.erb' if params['excel_layout'] == 'scoring_sheet'}
    end
  end
  
  def new
    @year = current_date.year
    @racer = Racer.new(:member_from => Date.new(@year))
    @race_numbers = []
    @years = (2005..(@year + 1)).to_a.reverse
    render(:action => "edit")
  end
  
  def edit
    @racer = Racer.find(params[:id])
    @year = current_date.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    @years = (2005..(@year + 1)).to_a.reverse
  end
  
  # Create new Racer
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
    @racer = Racer.create(params[:racer])
    
    if params[:number_value]
      params[:number_value].each_with_index do |number_value, index|
        unless number_value.blank?
          race_number = @racer.race_numbers.create(
            :discipline_id => params[:discipline_id][index], 
            :number_issuer_id => params[:number_issuer_id][index], 
            :year => params[:number_year],
            :value => number_value,
            :updated_by => session[:user].name
          )
          unless race_number.errors.empty?
            @racer.errors.add_to_base(race_number.errors.full_messages)
          end
        end
      end
    end
    if @racer.errors.empty?
      return redirect_to(:action => :edit, :id => @racer.to_param)
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    @year = params[:year] || current_date.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    render(:template => 'admin/racers/edit')
  end
  
  # Update existing Racer.
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
      @racer = Racer.find(params[:id])
      params[:racer][:updated_by] = session[:user].name
      @racer.update_attributes(params[:racer])
      if params[:number]
        for number_id in params[:number].keys
          number = RaceNumber.find(number_id)
          number_params = params[:number][number_id]
          if number.value != params[:number][number_id][:value]
            number_params[:updated_by] = session[:user].name
            RaceNumber.update(number_id, number_params)
          end
        end
      end
    
      if params[:number_value]
        params[:number_value].each_with_index do |number_value, index|
          unless number_value.blank?
            race_number = @racer.race_numbers.create(
              :discipline_id => params[:discipline_id][index], 
              :number_issuer_id => params[:number_issuer_id][index], 
              :year => params[:number_year],
              :value => number_value,
              :updated_by => session[:user].name
            )
            unless race_number.errors.empty?
              @racer.errors.add_to_base(race_number.errors.full_messages)
            end
          end
        end
      end
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      e.errors.each do |multi_param_error|
        @racer.errors.add(multi_param_error.attribute)
      end
    end

    if @racer.errors.empty?
      return redirect_to(:action => :edit, :id => @racer.to_param)
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    @year = params[:year] || Date.today.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    render(:template => 'admin/racers/edit')
  end
  
  # Preview contents of new members file from event registration service website like SignMeUp or Active.com.
  def preview_import
    if params[:racers_file].blank?
      flash[:warn] = "Choose a file of racers to import first"
      return redirect_to(:action => :index) 
    end

    path = "#{Dir.tmpdir}/#{params[:racers_file].original_filename}"
    File.open(path, File::CREAT|File::WRONLY) do |f|
      f.print(params[:racers_file].read)
    end

    temp_file = File.new(path)
    @racers_file = RacersFile.new(temp_file)
    if @racers_file
      assign_years
      session[:racers_file_path] = temp_file.path
    else
      redirect_to(:action => :index)
    end
  end
  
  def import
    if params[:commit] == 'Cancel'
      session[:racers_file_path] = nil
      redirect_to(:action => 'index')

    elsif params[:commit] == 'Import'
      Duplicate.delete_all
      path = session[:racers_file_path]
      if path.blank?
        flash[:warn] = "No import file"
        return redirect_to(admin_racers_path)
      end
      
      racers_file = RacersFile.new(File.new(path))
      racers_file.import(params[:update_membership], params[:year])
      flash[:notice] = "Imported #{pluralize(racers_file.created, 'new racer')} and updated #{pluralize(racers_file.updated, 'existing racer')}"
      session[:racers_file_path] = nil
      if racers_file.duplicates.empty?
        redirect_to(:action => 'index')
      else
        flash[:warn] = 'Some names in the import file already exist more than once. Match with an existing racer or create a new racer with the same name.'
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
      diff = (x.racer.last_name || '') <=> y.racer.last_name
      if diff == 0
        (x.racer.first_name || '') <=> y.racer.first_name
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
        duplicate.racer.save!
      elsif !id.blank?
        racer = Racer.update(id, duplicate.new_attributes)
        unless racer.valid?
          raise ActiveRecord::RecordNotSaved.new(racer.errors.full_messages.join(', '))
        end
      end
    end
  
    Duplicate.delete_all
    redirect_to(:action => 'index')
  end

  # Inline update. Merge with existing Racer if names match
  def set_racer_name
    @racer = Racer.find(params[:id])
    new_name = params[:value]
    original_name = @racer.name
    @racer.name = new_name

    racers_with_same_name = @racer.racers_with_same_name
    unless racers_with_same_name.empty?
      return merge?(original_name, racers_with_same_name, @racer)
    end
    
    @racer.update_attribute(:name, params[:value])
    expire_cache
    render :update do |page|
      page.replace_html("racer_#{@racer.id}_name", @racer.name)
    end
  end

  def toggle_member
    racer = Racer.find(params[:id])
    racer.toggle!(:member)
    render(:partial => "shared/member", :locals => { :record => racer })
  end
  
  def destroy
    @racer = Racer.find(params[:id])
    @racer.destroy
    respond_to do |format|
      format.html {redirect_to admin_racers_path}
      format.js
    end
    expire_cache
  end

  def merge?(original_name, existing_racers, racer)
    @racer = racer
    @existing_racers = existing_racers
    @original_name = original_name
    render :update do |page| 
      page.replace_html("racer_#{@racer.id}_row", :partial => 'merge_confirm', :locals => { :racer => @racer })
    end
  end
  
  def merge
    racer_to_merge_id = params[:id].gsub('racer_', '')
    @racer_to_merge = Racer.find(racer_to_merge_id)
    @merged_racer_name = @racer_to_merge.name
    @existing_racer = Racer.find(params[:target_id])
    @existing_racer.merge(@racer_to_merge)
    expire_cache
  end
  
  def cancel_in_place_edit
    racer_id = params[:id]
    render :update do |page|
      page.replace("racer_#{racer_id}_row", :partial => "racer", :locals => { :racer => Racer.find(racer_id) })
      page.call :restripeTable, :racers_table
    end
  end
  
  def number_year_changed
    @year = params[:year] || current_date.year
    if params[:id]
      @racer = Racer.find(params[:id])
      @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    else
      @racer = Racer.new
      @race_numbers = []
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    render(:partial => '/admin/racers/numbers', :locals => {:year => @year.to_i, :years => @years, :racer => @racer, :race_numbers => @race_numbers})
  end
  
  def new_number
    render :update do |page|
      page.insert_html(
        :before, 'new_number_button_row', 
        :partial => '/admin/racers/new_number', 
        :locals => {:discipline_id => Discipline[:road].id})
    end
  end
  
  def destroy_number
    id = params[:id]
    RaceNumber.destroy(id)
    render :update do |page|
      page.visual_effect(:puff, "number_#{id}_row", :duration => 2)
      page.remove("number_#{id}_row")
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
    @racers = Racer.find(:all, :conditions => ['print_card=?', true], :order => 'last_name, first_name')
    if @racers.empty?
      redirect_to(formatted_no_cards_admin_racers_path("html"))
    else
      Racer.update_all("print_card=0", ['id in (?)', @racers.collect{|racer| racer.id}])
    end
  end
  
  def card
    @racer = Racer.find(params[:id])
    @racers = [@racer]
    @racer.print_card = false
    @racer.save!
  end
  
  def mailing_labels
    @racers = Racer.find(:all, :conditions => ['print_mailing_label=?', true], :order => 'last_name, first_name')
    if @racers.empty?
      redirect_to(formatted_no_mailing_labels_admin_racers_path("html"))
    else
      Racer.update_all("print_mailing_label=0", ['id in (?)', @racers.collect{|racer| racer.id}])
    end
  end
  
  def rescue_action_in_public(exception)
    headers.delete("Content-Disposition")
    super
  end

  def rescue_action_locally(exception)
    headers.delete("Content-Disposition")
    super
  end
  
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
end
