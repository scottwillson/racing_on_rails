# Any way to not require render_page?
# Should provide sensible default if page is missing? Or just a 404?

# Thinking we have a catch-all controller that uses render inline,
# but could use a template handler with a comple method that queries DB?
# Template-finding seems to assume a file, though
class PagesController < ApplicationController
  def show
    if params[:path]
      path_params = params[:path].dup
      last_path = path_params.pop
      if last_path
        last_path.gsub!(/.html$/, "")
        if last_path && last_path != "index"
          path_params << last_path
        end
      end
      path = path_params.join("/")
    else
      path = ""
    end
    
    @page = Page.find_by_path(path)

    # Seems to be the best way to trigger a conventional Rails 404
    raise ActiveRecord::RecordNotFound.new("No page for /#{path}") unless @page

    render(:inline => @page.body, :layout => "application")
  end  
end
