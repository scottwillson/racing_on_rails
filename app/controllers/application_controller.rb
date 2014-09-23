require "action_controller/force_https"
require "sentient_user/sentient_controller"

class ApplicationController < ActionController::Base
  helper :all
  helper_method :page

  protect_from_forgery

  include ActionController::ForceHTTPS
  include Authentication
  include Authorization
  include Caching
  include Dates
  include Mobile
  include SentientController

  before_filter :clear_racing_association, :toggle_tabs


  protected

  def clear_racing_association
    RacingAssociation.current = nil
  end

  def toggle_tabs
    @show_tabs = false
  end

  def render_page(path = nil)
    unless path
      path = controller_path
      path = "#{path}/#{action_name}" unless action_name == "index"
    end

    page_path = path.dup
    page_path.gsub!(/.html$/, "")
    page_path.gsub!(/index$/, "")
    page_path.gsub!(/\/$/, "")

    @page = find_mobile_page(page_path)

    if !@page
      @page = Page.find_by_path(page_path)
    end

    if @page
      render(inline: @page.body, layout: true)
    end
  end

  def page
    begin
      if params[:page].to_i > 0
        params[:page].to_i
      end
    rescue
      nil
    end
  end

  private

  def secure_redirect_options
    if RacingAssociation.current.ssl?
      { protocol: "https", host: request.host, port: 443 }
    else
      {}
    end
  end

  def redirect_back_or_default(default)
    if session[:return_to]
      uri = URI.parse(session[:return_to])
      redirect_to URI::Generic.build(path: uri.path, query: uri.query).to_s
      session[:return_to] = nil
    else
      redirect_to default
    end
  end
end
