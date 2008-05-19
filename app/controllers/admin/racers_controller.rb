# Add, delete, and edit Racer information. Also merge 
class Admin::RacersController < Admin::RecordEditor

  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  edits :racer
  
  layout 'admin/application', :except => [:cards, :mailing_labels]
  exempt_from_layout 'xls.erb', 'ppl.erb'
  
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
  end
  
  def export
    today = Date.today
    if params['excel_layout'] == 'scoring_sheet'
      file_name = 'scoring_sheet.xls'
    elsif params['format'] == 'ppl'
      file_name = 'lynx.ppl'
    else
      file_name = "racers_#{today.year}_#{today.month}_#{today.day}.#{params['format']}"
    end
    headers['Content-Disposition'] = "filename=\"#{file_name}\""

    if params['include'] == 'members_only'
      where_clause = "WHERE (member_to >= \'#{today.strftime('%Y-%m-%d')}\')"
    end
    association_number_issuer_id = NumberIssuer.find_by_name(ASSOCIATION.short_name).id
    @racers = Racer.connection.select_all(%Q{
      SELECT license, first_name, last_name, teams.name as team_name, racers.notes,
             DATE_FORMAT(member_from, '%m/%d/%Y') as member_from, DATE_FORMAT(member_to, '%m/%d/%Y') as member_to,
             print_card, print_mailing_label, DATE_FORMAT(date_of_birth, '%m/%d/%Y') as date_of_birth, occupation, 
             street, racers.city, racers.state, zip, email, home_phone, work_phone, cell_fax, gender, 
             road_category, track_category, mtb_category, dh_category, CEILING(#{today.year} - YEAR(date_of_birth)) as racing_age,
             ccx_numbers.value as ccx_number, dh_numbers.value as dh_number, road_numbers.value as road_number, 
             singlespeed_numbers.value as singlespeed_number, xc_numbers.value as xc_number,
             DATE_FORMAT(racers.created_at, '%m/%d/%Y') as created_at, DATE_FORMAT(racers.updated_at, '%m/%d/%Y') as updated_at
      FROM racers
      LEFT OUTER JOIN teams ON teams.id = racers.team_id 
      LEFT OUTER JOIN race_numbers as ccx_numbers ON ccx_numbers.racer_id = racers.id 
                      and ccx_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and ccx_numbers.year = #{today.year} 
                      and ccx_numbers.discipline_id = #{Discipline[:ccx].id}
      LEFT OUTER JOIN race_numbers as dh_numbers ON dh_numbers.racer_id = racers.id 
                      and dh_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and dh_numbers.year = #{today.year} 
                      and dh_numbers.discipline_id = #{Discipline[:downhill].id}
      LEFT OUTER JOIN race_numbers as road_numbers ON road_numbers.racer_id = racers.id 
                      and road_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and road_numbers.year = #{today.year} 
                      and road_numbers.discipline_id = #{Discipline[:road].id}
      LEFT OUTER JOIN race_numbers as singlespeed_numbers ON singlespeed_numbers.racer_id = racers.id 
                      and singlespeed_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and singlespeed_numbers.year = #{today.year} 
                      and singlespeed_numbers.discipline_id = #{Discipline[:singlespeed].id}
      LEFT OUTER JOIN race_numbers as track_numbers ON track_numbers.racer_id = racers.id 
                      and track_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and track_numbers.year = #{today.year} 
                      and track_numbers.discipline_id = #{Discipline[:track].id}
      LEFT OUTER JOIN race_numbers as xc_numbers ON xc_numbers.racer_id = racers.id 
                      and xc_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and xc_numbers.year = #{today.year} 
                      and xc_numbers.discipline_id = #{Discipline[:mountain_bike].id}
      #{where_clause}
      ORDER BY last_name, first_name
    })

    respond_to do |format|
      format.html
      format.ppl
      format.xls {render :template => 'admin/racers/scoring_sheet.xls.erb' if params['excel_layout'] == 'scoring_sheet'}
    end
  end
  
  def new
    @year = Date.today.year
    @racer = Racer.new(:member_from => Date.new(@year))
    @race_numbers = []
    @years = (2005..(@year + 1)).to_a.reverse
    render(:template => '/admin/racers/show')
  end
  
  def show
    @racer = Racer.find(params[:id])
    @year = Date.today.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    @years = (2005..(@year + 1)).to_a.reverse
  end
  
  # Inline edit
  def edit_name
    @racer = Racer.find(params[:id])
    expire_cache
    render(:partial => 'edit')
  end

  # Inline edit
  def edit_team_name
    @racer = Racer.find(params[:id])
    expire_cache
    render(:partial => 'edit_team_name')
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
    begin
      expire_cache
      @racer = Racer.create(params[:racer])
      
      if params[:number_value]
        params[:number_value].each_with_index do |number_value, index|
          unless number_value.blank?
            race_number = @racer.race_numbers.create(
              :discipline_id => params[:discipline_id][index], 
              :number_issuer_id => params[:number_issuer_id][index], 
              :year => params[:number_year],
              :value => number_value
            )
            unless race_number.errors.empty?
              @racer.errors.add_to_base(race_number.errors.full_messages)
            end
          end
        end
      end
      if @racer.errors.empty?
        return redirect_to(:action => :show, :id => @racer.to_param)
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      flash[:warn] = e.to_s
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    @year = params[:year] || Date.today.year
    render(:template => 'admin/racers/show')
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
      @racer.update_attributes(params[:racer])
      if params[:number]
        for id in params[:number].keys
          RaceNumber.update(id, params[:number][id])
        end
      end
      
      if params[:number_value]
        params[:number_value].each_with_index do |number_value, index|
          unless number_value.blank?
            race_number = @racer.race_numbers.create(
              :discipline_id => params[:discipline_id][index], 
              :number_issuer_id => params[:number_issuer_id][index], 
              :year => params[:number_year],
              :value => number_value
            )
            unless race_number.errors.empty?
              @racer.errors.add_to_base(race_number.errors.full_messages)
            end
          end
        end
      end
      if @racer.errors.empty?
        return redirect_to(:action => :show, :id => @racer.to_param)
      end
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      e.errors.each do |multi_param_error|
        @racer.errors.add(multi_param_error.attribute)
      end
    rescue Exception => e
      begin
        stack_trace = e.backtrace.join("\n")
        logger.error("#{e}\n#{stack_trace}")
        ExceptionNotifier.deliver_exception_notification(e, self, request, {})
        flash[:warn] = e.to_s
      end
    end
    @years = (2005..(Date.today.year + 1)).to_a.reverse
    @year = params[:year] || Date.today.year
    @race_numbers = RaceNumber.find(:all, :conditions => ['racer_id=? and year=?', @racer.id, @year], :order => 'number_issuer_id, discipline_id')
    render(:template => 'admin/racers/show')
  end
  
  # Preview contents of new members file from event registration service website like SignMeUp or Active.com.
  def preview_import
    uploaded_file = params[:racers_file]
    path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
    File.open(path, File::CREAT|File::WRONLY) do |f|
      f.print(uploaded_file.read)
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
      begin
        Duplicate.delete_all
        path = session[:racers_file_path]
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
      rescue Exception => e
        stack_trace = e.backtrace.join("\n")
        logger.error("#{e}\n#{stack_trace}")
        flash[:warn] = e.to_s
        if path
          temp_file = File.new(path)
          @racers_file = RacersFile.new(temp_file)
        end
        assign_years
        @year = params[:year] if params[:year]
        render(:template => 'admin/racers/preview_import')
      end

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
    begin
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
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      flash[:warn] = e.to_s
      render(:template => 'admin/racers/duplicates')
    end
  end

  # Inline update. Merge with existing Racer if names match
  def update_name
    new_name = params[:name]
    racer_id = params[:id]
    @racer = Racer.find(racer_id)
    original_name = @racer.name
    @racer.name = new_name
    existing_racers = Racer.find_all_by_name(new_name) | Alias.find_all_racers_by_name(new_name)
    existing_racers.reject! {|racer| racer == @racer}
    if existing_racers.size > 0
      return merge?(original_name, existing_racers, @racer)
    end
    
    saved = @racer.save
    if saved
      expire_cache
      attribute(@racer, 'name')
    else
      render(:partial => 'edit')
    end
  end
  
  # Inline
  def update_team_name
    @racer = Racer.find(params[:id])
    new_name = params[:team_name]
    @racer.team_name = new_name
    saved = @racer.save
    begin
      if saved
        expire_cache
        render(:partial => 'team', :locals => {:racer => @racer})
      else
        render(:partial => 'edit_team_name', :locals => {:racer => @racer})
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{e}\n#{stack_trace}")
      @racer.errors.add('team_name', e)
      render(:partial => 'edit_team_name', :locals => {:racer => @racer})
    end
  end
  
  # Cancel inline editing
  def cancel
    if params[:id]
      @racer = Racer.find(params[:id])
      attribute(@racer, 'name')
    else
      render(:text => '<tr><td colspan=4></td></tr>')
    end
  end
  
  # Cancel inline editing
  def cancel_edit_team_name
    @racer = Racer.find(params[:id])
    render(:partial => 'team', :locals => {:racer => @racer})
  end
  
  def destroy
    @racer = Racer.find(params[:id])
    begin
      @racer.destroy
      respond_to do |format|
        format.html {redirect_to admin_racers_path}
        format.js
      end
      expire_cache
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{@racer.name}"
      render :update do |page|
        page.replace_html("message_#{@racer.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end

  def merge?(original_name, existing_racers, racer)
    @racer = racer
    @existing_racers = existing_racers
    @original_name = original_name
    render(:partial => 'merge_confirm')
  end
  
  def merge
    racer_to_merge_id = params[:id].gsub('racer_', '')
    racer_to_merge = Racer.find(racer_to_merge_id)
    @merged_racer_name = racer_to_merge.name
    @existing_racer = Racer.find(params[:target_id])
    @existing_racer.merge(racer_to_merge)
    expire_cache
  end
  
  def number_year_changed
    @year = params[:year] || Date.today.year
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
      render(:action => :no_cards)
    else
      render(:template => 'admin/racers/cards')
      Racer.update_all("print_card=0", ['id in (?)', @racers.collect{|racer| racer.id}])
    end
  end
  
  def print_one_card
    @racer = Racer.find(params[:id])
    @racers = [@racer]
    render(:template => 'admin/racers/cards')
    @racer.print_card = false
    @racer.save!
  end
  
  def mailing_labels
    @racers = Racer.find(:all, :conditions => ['print_mailing_label=?', true], :order => 'last_name, first_name')
    if @racers.empty?
      render(:action => :no_mailing_labels)
    else
      render(:template => 'admin/racers/mailing_labels')
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
    today = Date.today
    if today.month == 12
      @year = today.year + 1
    else
      @year = today.year
    end
    @years = [today.year, today.year + 1]
  end
end
