# TODO Auto-size editing page textarea
# TODO Consolidate duplicated Page finding code
# TODO Page link helpers?
# TODO Consider FKs and indexes
# TODO Caching
# TODO Partials should respect relative paths
# TODO Diff pages
# TODO Keywords?
# TODO Other mark-up?
# TODO Import/export as YAML
# TODO Auto-refresh preview
# TODO Change parent to child (requires fancier logic. For now, just move page to root first)
# TODO publish-on dates
class Admin::PagesController < ApplicationController
  before_filter :check_administrator_role, :except => [ :show ]
  in_place_edit_for :page, :title
  layout "admin/application"

  def index
    @pages = Page.roots
  end
  
  def new
    @page = Page.new(params[:page])
    render(:edit)
  end
  
  def create
    @page = Page.new(params["page"])
    @page.author = logged_in_user
    @page.save
    if @page.errors.empty?
      flash[:notice] = "Created #{@page.title}"
      expire_cache
      redirect_to(edit_admin_page_path(@page))
    else
      render(:edit)
    end
  end
  
  def edit
    @page = Page.find(params[:id])
  end
  
  def update
    @page = Page.find(params[:id])
    @page.author = logged_in_user
    if @page.update_attributes(params[:page])
      flash[:notice] = "Updated #{@page.title}"
      expire_cache
      redirect_to(edit_admin_page_path(@page))
    else
      render(:action => :edit)
    end
  end
  
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    expire_cache
    flash[:notice] = "Deleted #{@page.title}"
    redirect_to admin_pages_path
  end
end
