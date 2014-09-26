module Admin
  module Pages
    # Show old versions of Pages
    class VersionsController < Admin::AdminController
      def edit
        @version = Page::Version.find(params[:id])
        @page = @version.versioned
        # The _new_ version of the old parent, which may be confusing
        @parent = Page.find(@version.versioned.parent_id) if @version.versioned.parent_id
      end

      def show
        @version = Page::Version.find(params[:id])
        @page = @version.versioned
        render inline: @version.versioned.body, layout: "application"
      end

      def destroy
        @version = Page::Version.find(params[:id])
        @page = @version.versioned
        @version.destroy
        flash[:notice] = "Deleted #{@version.versioned.title}"
        redirect_to edit_admin_page_path(@version.versioned)
      end

      # Revert to +version+
      def revert
        version = Page::Version.find(params[:id])
        page = version.versioned

        page.revert_to! version.number

        expire_cache
        flash[:notice] = "Reverted #{page.title} to version from #{version.updated_at.to_s(:long)}"
        redirect_to edit_admin_page_path(page)
      end
    end
  end
end
