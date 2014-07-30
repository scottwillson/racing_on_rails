module Admin
  # All succcessful edit expire cache.
  class VelodromesController < Admin::AdminController
    def index
      @velodromes = Velodrome.order(:name)
    end

    def new
      @velodrome = Velodrome.new
      render :edit
    end

    def create
      @velodrome = Velodrome.create(velodrome_params)

      if @velodrome.errors.empty?
        flash[:notice] = "Created #{@velodrome.name}"
        return redirect_to(new_admin_velodrome_path)
      end
      render(template: 'admin/velodromes/edit')
    end

    def edit
      @velodrome = Velodrome.find(params[:id])
    end

    def update
      @velodrome = Velodrome.find(params[:id])

      if @velodrome.update(velodrome_params)
        flash[:notice] = "Updated #{@velodrome.name}"
        return redirect_to(edit_admin_velodrome_path(@velodrome))
      end
      render(template: 'admin/velodromes/edit')
    end

    def update_attribute
      respond_to do |format|
        format.js do
          @velodrome = Velodrome.find(params[:id])
          @velodrome.update! params[:name] => params[:value]
          render plain: @velodrome.send(params[:name])
        end
      end
    end

    def destroy
      @velodrome = Velodrome.find(params[:id])
      flash[:notice] = "Deleted #{@velodrome.name}"
      @velodrome.destroy
      redirect_to(admin_velodromes_path)
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "Velodromes"
    end


    private

    def velodrome_params
      params_without_mobile.require(:velodrome).permit(:name, :website)
    end
  end
end
