module RacingOnRails
  module Controllers
    module Authentication
      extend ActiveSupport::Concern
      
      included do
        helper_method :current_person
        helper_method :current_person_session
      end
      
      private

      def assign_person
        @person = Person.find(params[:id])
      end

      def current_person_session
        return @current_person_session if defined?(@current_person_session)
        @current_person_session = PersonSession.find
      end

      def current_person
        return @current_person if defined?(@current_person)
        @current_person = current_person_session && current_person_session.person
      end

      def store_location_and_redirect_to_login
        if request.format == "text/javascript"
          session[:return_to] = request.referrer
          @redirect_to = new_person_session_url(secure_redirect_options)
          render :template => "redirect"
        else
          session[:return_to] = request.fullpath
          redirect_to new_person_session_url(secure_redirect_options)
        end
      end
    end
  end
end