require "action_controller/force_https"
require "sentient_user/sentient_controller"

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  include ActionController::ForceHTTPS
  include Authentication
  include Authorization
  include Caching
  include Mobile
  include SentientController

  before_filter :clear_racing_association, :toggle_tabs, :assign_year


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

  def render_404
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/404.html"
        if File.exist?(local_path)
          render file: "#{::Rails.root}/local/public/404.html", status: "404 Not Found"
        else
          render file: "#{::Rails.root}/public/404.html", status: "404 Not Found"
        end
      }
      type.all { render nothing: true, status: "404 Not Found" }
    end
  end

  def render_500
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/500.html"
        if File.exist?(local_path)
          render file: "#{::Rails.root}/local/public/500.html", status: "500 Error"
        else
          render file: "#{::Rails.root}/public/500.html", status: "500 Error"
        end
      }
      type.all { render nothing: true, status: "500 Error" }
    end
  end

  def assign_year
    if params[:year] && params[:year][/^\d\d\d\d$/]
      @year = params[:year].to_i
    end

    if @year.nil? || @year < 1900 || @year > 2100
      @year = RacingAssociation.current.effective_year
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
