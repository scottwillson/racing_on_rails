module Mobile
  extend ActiveSupport::Concern

  included do
    before_filter :set_mobile_preferences, :redirect_to_mobile_if_applicable, :prepend_view_path_if_mobile

    helper_method :mobile_browser?
    helper_method :mobile_request?
  end

  def default_url_options(options = {})
    if mobile_request?
      options[:mobile] = "m"
    else
      options[:mobile] = nil
    end
    options
  end

  private

  def prepend_view_path_if_mobile
    if mobile_request?
      prepend_view_path "app/views/mobile"
    end
  end

  def find_mobile_page(page_path)
    if mobile_request?
      Page.find_by_path("mobile/#{page_path}")
    end
  end

  def params_without_mobile
    _params = params.dup
    _params.delete :mobile
    _params
  end

  def mobile_browser?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"].downcase =~ /'palm|blackberry|nokia|phone|midp|symbian|chtml|ericsson|minimo|'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer'/
  end

  def mobile_request?
    params[:mobile] == "m"
  end

  def set_mobile_preferences
    if params[:mobile_site] && params[:full_site]
      cookies.delete(:prefer_full_site)
    elsif params[:mobile_site]
      cookies.delete(:prefer_full_site)
      redirect_to_mobile if !mobile_request?
    elsif params[:full_site]
      cookies.permanent[:prefer_full_site] = 1
      redirect_to_full_site if mobile_request?
    end
  end

  def redirect_to_mobile_if_applicable
    if !mobile_request? && request.get? && !cookies[:prefer_full_site] && mobile_browser?
      redirect_to_mobile
    end
  end

  def redirect_to_mobile
    redirect_to request.protocol +
                request.host_with_port +
                "/m" +
                request.fullpath.
                gsub(/[\?&]mobile_site=1/, "").
                gsub(/[\?&]full_site=1/, "") and return
  end

  def redirect_to_full_site
    redirect_to request.protocol +
                request.host_with_port +
                request.fullpath.
                gsub(%r{^/m}, "").
                gsub(/[\?&]mobile_site=1/, "").
                gsub(/[\?&]full_site=1/, "") and return
  end
end
