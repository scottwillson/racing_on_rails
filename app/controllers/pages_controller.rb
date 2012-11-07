# Any way to not require render_page?
# Should provide sensible default if page is missing? Or just a 404?

# Thinking we have a catch-all controller that uses render inline,
# but could use a template handler with a comple method that queries DB?
# Template-finding seems to assume a file, though
class PagesController < ApplicationController
  def show
    @page = Page.find_by_normalized_path!(params[:path])
    render :inline => @page.body, :layout => "application"
  end  
end
