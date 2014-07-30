module Admin
  # Admin editing for Pages in built-in CMS. All editing actions expire the cache.
  class PagesController < Admin::AdminController
    before_filter :require_administrator, except: [ :show ]

    def index
      @pages = Page.roots
    end

    def new
      if params[:page]
        @page = Page.new(page_params)
      else
        @page = Page.new
      end
      render :edit
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        flash[:notice] = "Created #{@page.title}"
        redirect_to(edit_admin_page_path(@page))
      else
        render :edit
      end
    end

    def edit
      @page = Page.find(params[:id])
    end

    def update
      @page = Page.find(params[:id])
      if @page.update(page_params)
        flash[:notice] = "Updated #{@page.title}"
        redirect_to(edit_admin_page_path(@page))
      else
        render :edit
      end
    end

    def update_attribute
      respond_to do |format|
        format.js {
          @page = Page.find(params[:id])
          @page.update! params[:name] => params[:value]
          render plain: @page.send(params[:name])
        }
      end
    end

    def destroy
      @page = Page.find(params[:id])
      begin
        ActiveRecord::Base.lock_optimistically = false
        @page.destroy
      ensure
        ActiveRecord::Base.lock_optimistically = true
      end

      flash[:notice] = "Deleted #{@page.title}"
      redirect_to admin_pages_path
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "Pages"
    end


    private

    def page_params
      params_without_mobile.require(:page).permit(:body, :parent_id, :path, :slug, :title)
    end
  end
end
