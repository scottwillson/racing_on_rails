class Admin::VelodromesController < ApplicationController
  before_filter :check_administrator_role
  layout "admin/application"
  
  in_place_edit_for :velodrome, :name
  in_place_edit_for :velodrome, :website

  def index
    @velodromes = Velodrome.find(:all, :order => "name")
  end
  
  def new
    @velodrome = Velodrome.new
    render :action => "edit"
  end
  
  def create
    expire_cache
    @velodrome = Velodrome.create(params[:velodrome])
    
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
    
    if @velodrome.update_attributes(params[:velodrome])
      flash[:notice] = "Updated #{@velodrome.name}"
      return redirect_to(edit_admin_velodrome_path(@velodrome))
    end
    render(:template => 'admin/velodromes/edit')
  end

  def destroy
    @velodrome = Velodrome.find(params[:id])
    flash[:notice] = "Deleted #{@velodrome.name}"
    @velodrome.destroy
    redirect_to(admin_velodromes_path)
    expire_cache
  end
end
