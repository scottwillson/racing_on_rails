class Admin::Pages::VersionsController < Admin::AdminController
  before_filter :require_administrator
  layout "admin/application"

  def edit
    @version = Page::Version.find(params[:id])
    # The _new_ version of the old parent, which may be confusing
    @parent = Page.find(@version.parent_id) if @version.parent_id
  end

  def show
    @version = Page::Version.find(params[:id])
    render(:inline => @version.body, :layout => "application")
  end
  
  def destroy
    @version = Page::Version.find(params[:id])
    @version.destroy
    flash[:notice] = "Deleted #{@version.title}"
    redirect_to(edit_admin_page_path(@version.page))
  end
  
  def revert
    version = Page::Version.find(params[:id])
    page = version.page
    version.page.revert_to!(version)
    expire_cache
    flash[:notice] = "Reverted #{version.title} to version from #{version.updated_at.to_s(:long)}"
    redirect_to(edit_admin_page_path(version.page))
  end
end
