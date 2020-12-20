# frozen_string_literal: true

module Admin
  # Admin editing for Pages in built-in CMS. All editing actions expire the cache.
  class PagesController < Admin::AdminController
    before_action :require_administrator, except: [:show]

    def index
      @pages = Page.roots
    end

    def new
      @page = if params[:page]
                Page.new(page_params)
              else
                Page.new
              end
      render :edit
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        flash[:notice] = "Created #{@page.title}"
        expire_cache
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
        expire_cache
        redirect_to(edit_admin_page_path(@page))
      else
        render :edit
      end
    end

    def update_attribute
      respond_to do |format|
        format.js do
          @page = Page.find(params[:id])
          @page.update! params[:name] => params[:value]
          expire_cache
          render plain: @page.send(params[:name]), content_type: "text/plain"
        end
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.destroy

      expire_cache
      flash[:notice] = "Deleted #{@page.title}"
      redirect_to admin_pages_path
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "Pages"
    end

    private

    def page_params
      params.require(:page).permit(:body, :parent_id, :path, :slug, :title)
    end
  end
end
