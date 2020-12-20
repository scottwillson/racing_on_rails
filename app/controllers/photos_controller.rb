# frozen_string_literal: true

class PhotosController < Admin::AdminController
  before_action :assign_current_admin_tab

  def index
    @photos = Photo.order("updated_at desc").page(page)
  end

  def new
    @photo = Photo.new

    render :edit
  end

  def create
    @photo = Photo.create(photo_params)

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
    @photo = Photo.find(params[:id])

    if @photo.update(photo_params)
      expire_cache
      flash[:notice] = "Updated photo"
      return redirect_to(edit_photo_path(@photo))
    end
    render :edit
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = "Photos"
    @show_tabs = true
  end

  private

  def photo_params
    params.require(:photo).permit(:caption, :height, :image, :image_cache, :link, :title, :width)
  end
end
