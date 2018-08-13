# frozen_string_literal: true

require "action_controller/force_https"
require "sentient_user/sentient_controller"

class ApplicationController < ActionController::Base
  helper :all
  helper_method :use_https?
  helper_method :page

  protect_from_forgery with: :exception

  include ActionController::ForceHTTPS
  include Authentication
  include Authorization
  include Caching
  include Dates
  include Mobile
  include SentientController

  before_action :clear_racing_association, :toggle_tabs, :allow_iframes, :set_paper_trail_whodunnit

  protected

  def clear_racing_association
    RacingAssociation.current = nil
  end

  def toggle_tabs
    @show_tabs = false
  end

  def allow_iframes
    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM http://www.albertabicycle.ab.ca" if RacingAssociation.current.allow_iframes?
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

    @page ||= Page.find_by(path: page_path)

    render(inline: @page.body, layout: true) if @page
  end

  def page
    params[:page].to_i if params[:page].to_i > 0
  rescue StandardError
    nil
  end

  def user_for_paper_trail
    current_person&.name_or_login
  end


  private

  def secure_redirect_options
    if use_https?
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
