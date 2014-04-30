  module Authorization
    extend ActiveSupport::Concern

    private

    def require_current_person
      unless current_person
        flash[:notice] = "Please login to your #{RacingAssociation.current.short_name} account"
        store_location_and_redirect_to_login
        return false
      end
      true
    end

    def require_administrator
      unless require_current_person
        return false
      end

      unless current_person.administrator?
        session[:return_to] = request.fullpath
        flash[:notice] = "You must be an administrator to access this page"
        store_location_and_redirect_to_login
        return false
      end
      true
    end

    def require_administrator_or_promoter
      unless require_current_person
        return false
      end

      unless administrator? ||
             (@event && (current_person == @event.promoter || @event.editors.include?(current_person))) ||
             (@race && (current_person == @race.event.promoter || @race.event.editors.include?(current_person)))

        redirect_to unauthorized_path
        return false
      end
      true
    end

    def require_administrator_or_official
      unless require_current_person
        return false
      end

      unless administrator? || official?
        session[:return_to] = request.fullpath
        flash[:notice] = "You must be an official or administrator to access this page"
        store_location_and_redirect_to_login
        return false
      end
      true
    end

    def require_same_person_or_administrator
      unless require_current_person
        return false
      end

      unless administrator? || (@person && current_person == @person)
        redirect_to unauthorized_path
        return false
      end
      true
    end

    def require_same_person_or_administrator_or_editor
      unless require_current_person
        return false
      end

      unless administrator? || (@person && current_person == @person) || (@person && @person.editors.include?(current_person))
        redirect_to unauthorized_path
        return false
      end
      true
    end

    def require_administrator_or_promoter_or_official
      unless require_current_person
        return false
      end

      unless administrator? || promoter? || official?
        redirect_to unauthorized_path
        return false
      end
      true
    end

    def require_administrator_or_same_person
      unless current_person.administrator? || (current_person == @person)
        redirect_to unauthorized_path
      end
    end

    def administrator?
      current_person.try :administrator?
    end

    def official?
      current_person.try :official?
    end

    def promoter?
      current_person.try :promoter?
    end
  end
