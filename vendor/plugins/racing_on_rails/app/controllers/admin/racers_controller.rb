# Add, delete, and edit Racer information. Also merge 
class Admin::RacersController < Admin::RecordEditor

  include ApplicationHelper

  model :racer
  edits :racer
  
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
    @name = @params['name'] || @session['racer_name'] || cookies[:racer_name] || ''
    if @name.blank?
      @racers = []
    else
      @session['racer_name'] = @name
      cookies[:racer_name] = {:value => @name, :expires => Time.now + 36000}
      name_like = "%#{@name}%"
      @racers = Racer.find(
        :all, 
        :conditions => ["concat(first_name, ' ', last_name) like ?", "%#{@name}%"],
        :include => :aliases,
        :limit => RESULTS_LIMIT,
        :order => 'last_name, first_name'
      )
      if @racers.size == RESULTS_LIMIT
        flash[:notice] = "First #{RESULTS_LIMIT} racers"
      end
    end
  end
  
  def new
    @racer = Racer.new
    render('/admin/racers/show')
  end
  
  def show
    @racer = Racer.find(params[:id])
  end
  
  def edit_name
    @racer = Racer.find(@params[:id])
    render(:partial => 'edit')
  end

  def edit_team_name
    @racer = Racer.find(@params[:id])
    render(:partial => 'edit_team_name')
  end
  
  def update
    begin
      if params[:id]
        @racer = Racer.update(params[:id], params[:racer])
      else
        @racer = Racer.new(params[:racer])
        @racer.save
      end
      if @racer.errors.empty?
        return redirect_to(:action => :show, :id => @racer.to_param)
      end
    rescue Exception => e
      begin
        # try to redisplay racer
        @racer = Racer.find(params[:id])
      ensure
        RACING_ON_RAILS_DEFAULT_LOGGER.error(e)
        flash[:warn] = e
      end
    end
    render('admin/racers/show')
  end

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
    old_alias = @racer.aliases.detect {|a| a.name.casecmp(new_name) == 0}
    if old_alias
      old_alias.name = original_name
      old_alias.save!
    end
    
    saved = @racer.save
    if saved
      attribute(@racer, 'name')
    else
      render(:partial => 'edit')
    end
  end
  
  def update_team_name
    @racer = Racer.find(@params[:id])
    new_name = params[:team_name]
    @racer.team_name = new_name
    saved = @racer.save
    begin
      if saved
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
  
  def cancel
    if @params[:id]
      @racer = Racer.find(@params[:id])
      attribute(@racer, 'name')
    else
      render(:text => '<tr><td colspan=4></td></tr>')
    end
  end
  
  def cancel_edit_team_name
    @racer = Racer.find(@params[:id])
    render(:partial => 'team', :locals => {:racer => @racer})
  end
  
  def destroy
    racer = Racer.find(params[:id])
    begin
      racer.destroy
      render :update do |page|
        page.visual_effect(:puff, "racer_#{racer.id}_row", :duration => 2)
        page.replace_html(
          'message', 
          "#{image_tag('icons/confirmed.gif', :height => 11, :width => 11, :id => 'confirmed') } Deleted #{racer.name}"
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{racer.name}"
      render :update do |page|
        page.replace_html("message_#{racer.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
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
    racer_to_merge_id = @params[:id].gsub('racer_', '')
    racer_to_merge = Racer.find(racer_to_merge_id)
    @merged_racer_name = racer_to_merge.name
    @existing_racer = Racer.find(@params[:target_id])
    @existing_racer.merge(racer_to_merge)
  end
end
