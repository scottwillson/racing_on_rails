module Admin
  # All succcessful edit expire cache.
  class VelodromesController < Admin::AdminController
    def index
      @velodromes = Velodrome.order(:name)
    end
  
    def new
      @velodrome = Velodrome.new
      render :action => "edit"
    end
  
    def create
      expire_cache
      @velodrome = Velodrome.create(velodrome_params)
    
      if @velodrome.errors.empty?
        flash[:notice] = "Created #{@velodrome.name}"
        return redirect_to(new_admin_velodrome_path)
      end
      render(:template => 'admin/velodromes/edit')
    end
  
    def edit
      @velodrome = Velodrome.find(params[:id])
    end
  
    def update
      expire_cache
      @velodrome = Velodrome.find(params[:id])
    
      if @velodrome.update_attributes(velodrome_params)
        flash[:notice] = "Updated #{@velodrome.name}"
        return redirect_to(edit_admin_velodrome_path(@velodrome))
      end
      render(:template => 'admin/velodromes/edit')
    end

    def update_attribute
      respond_to do |format|
        format.js {
          @velodrome = Velodrome.find(params[:id])
          @velodrome.update_attributes! params[:name] => params[:value]
          expire_cache
          render :text => @velodrome.send(params[:name]), :content_type => "text/html"
        }
      end
    end

    def destroy
      @velodrome = Velodrome.find(params[:id])
      flash[:notice] = "Deleted #{@velodrome.name}"
      @velodrome.destroy
      redirect_to(admin_velodromes_path)
      expire_cache
    end
  
    protected

    def assign_current_admin_tab
      @current_admin_tab = "Velodromes"
    end


    private

    def velodrome_params
      params.require(:velodrome).permit(:name, :website)
    end
  end
end
