class Admin::VelodromesController < Admin::RecordEditor
  def index
    @velodromes = Velodrome.find(:all, :order => "name")
  end
  
  def new
    @velodrome = Velodrome.new
    render :action => "edit"
  end
  
  def create
    begin
      expire_cache
      @velodrome = Velodrome.create(params[:velodrome])
      
      if @velodrome.errors.empty?
        flash[:notice] = "Created #{@velodrome.name}"
        return redirect_to(new_admin_velodrome_path)
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      flash[:warn] = e.to_s
    end
    render(:template => 'admin/velodromes/edit')
  end
  
  def update
    begin
      expire_cache
      @velodrome = Velodrome.find(params[:id])
      
      if @velodrome.update_attributes(params[:velodrome])
        flash[:notice] = "Updated #{@velodrome.name}"
        return redirect_to(edit_admin_velodrome_path(@velodrome))
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      flash[:warn] = e.to_s
    end
    render(:template => 'admin/velodromes/edit')
  end
  
  def edit
    @velodrome = Velodrome.find(params[:id])
  end

  def edit_name
    @velodrome = Velodrome.find(params[:id])
    render(:partial => "edit_name", :locals => { :velodrome => @velodrome })
  end
  
  # Inline update
  def update_name
    new_name = params[:name]
    velodrome_id = params[:id]
    @velodrome = Velodrome.find(velodrome_id)
    begin
      original_name = @velodrome.name
      @velodrome.name = new_name

      if @velodrome.save
        expire_cache
        render :update do |page| page.replace_html("velodrome_#{@velodrome.id}_name", :partial => 'name', :locals => { :velodrome => @velodrome }) end
      else
        render :update do |page|
          page.replace_html("velodrome_#{@velodrome.id}_name", :partial => 'edit', :locals => { :velodrome => @velodrome })
          @velodrome.errors.full_messages.each do |message|
            page.insert_html(:after, "velodrome_#{@velodrome.id}_row", :partial => 'error', :locals => { :error => message })
          end
        end
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      render :update do |page|
        if @velodrome
          page.insert_html(:after, "velodrome_#{@velodrome.id}_row", :partial => 'error', :locals => { :error => e })
        else
          page.alert(e.message)
        end
      end
    end
  end
  
  # Cancel inline editing
  def test_cancel_edit_name
    @velodrome = Velodrome.find(params[:id])
    render(:partial => 'name', :locals => {:velodrome => @velodrome})
  end
  
  def edit_website
    @velodrome = Velodrome.find(params[:id])
    render(:partial => "edit_website", :locals => { :velodrome => @velodrome })
  end
  
  # Inline update
  def update_website
    new_website = params[:website]
    velodrome_id = params[:id]
    @velodrome = Velodrome.find(velodrome_id)
    begin
      original_website = @velodrome.website
      @velodrome.website = new_website

      if @velodrome.save
        expire_cache
        render :update do |page| page.replace_html("velodrome_#{@velodrome.id}_website", :partial => 'website', :locals => { :velodrome => @velodrome }) end
      else
        render :update do |page|
          page.replace_html("velodrome_#{@velodrome.id}_website", :partial => 'edit', :locals => { :velodrome => @velodrome })
          @velodrome.errors.full_messages.each do |message|
            page.insert_html(:after, "velodrome_#{@velodrome.id}_row", :partial => 'error', :locals => { :error => message })
          end
        end
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      render :update do |page|
        if @velodrome
          page.insert_html(:after, "velodrome_#{@velodrome.id}_row", :partial => 'error', :locals => { :error => e })
        else
          page.alert(e.message)
        end
      end
    end
  end
  
  # Cancel inline editing
  def test_cancel_edit_website
    @velodrome = Velodrome.find(params[:id])
    render(:partial => 'website', :locals => {:velodrome => @velodrome})
  end

  def destroy
    @velodrome = Velodrome.find(params[:id])
    @velodrome.destroy
    flash[:notice] = "Deleted #{@velodrome.website}"
    
    respond_to do |format|
      format.html { redirect_to(admin_velodromes_url) }
      format.js
    end
  end
end
