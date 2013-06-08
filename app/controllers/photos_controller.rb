class PhotosController < Admin::AdminController
  before_filter :assign_current_admin_tab

  def index
    @photos = Photo.all
  end

  def new
    @photo = Photo.new
    
    render :edit
  end
  
  def create
    expire_cache
    @photo = Photo.create(params[:photo])
    
    if @photo.errors.empty?
      flash[:notice] = "Created photo"
      return redirect_to(edit_photo_path(@photo))
    end
    render :edit
  end
  
  def edit
    @photo = Photo.find(params[:id])
  end

  def update
    expire_cache
    @photo = Photo.find(params[:id])
    
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Updated photo"
      return redirect_to(edit_photo_path(@photo))
    end
    render :edit
  end
  
  def assign_current_admin_tab
    @current_admin_tab = "Photos"
    @show_tabs = true
  end
end
