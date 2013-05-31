module RacingOnRails
  module Controllers
    module Mobile
      extend ActiveSupport::Concern
      
      included do
        before_filter :set_mobile_preferences, :redirect_to_mobile_if_applicable, :prepend_view_path_if_mobile

        helper_method :mobile_browser?
        helper_method :mobile_request?
      end

      def prepend_view_path_if_mobile
        if mobile_request?
          prepend_view_path "app/views/mobile"
        end
      end

      def mobile_browser?
        request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod|Android)/]
      end

      def mobile_request?
        request.subdomains.first == 'm'
      end

      def set_mobile_preferences
        if params[:mobile_site]
          cookies.delete(:prefer_full_site)
        elsif params[:full_site]
          cookies.permanent[:prefer_full_site] = 1
          redirect_to_full_site if mobile_request?
        end
      end

      def redirect_to_full_site
        redirect_to request.protocol + request.host_with_port.gsub(/^m\./, '') +
                    request.fullpath.gsub("mobile_site=1", "") and return
      end

      def redirect_to_mobile_if_applicable
        unless mobile_request? || cookies[:prefer_full_site] || !mobile_browser? || !RacingAssociation.current.mobile_site?
          redirect_to request.protocol + "m." + request.host_with_port.gsub(/^www\./, '') +
                      request.fullpath and return
        end
      end
    end
  end
end
