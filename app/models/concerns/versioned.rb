module Concerns
  module Versioned
    extend ActiveSupport::Concern
    
    included do
      versioned :except => [ :current_login_at, :current_login_ip, :last_login_at, :last_login_ip, :login_count, :password_salt, 
                             :perishable_token, :persistence_token, :single_access_token ],
                :initial_version => true
      before_save :set_updated_by
    end

    def created_by
      versions.first.try :user
    end

    def updated_by_person
      versions.last.try :user
    end

    def set_updated_by
      self.updated_by ||= ::Person.current
      true
    end
      
    def updated_by_person_name
      case updated_by_person
      when nil
        ""
      when String
        updated_by_person
      else
        updated_by_person.name
      end
    end

    def created_from_result?
      created_by.present? && created_by.kind_of?(::Event)
    end
      
    def updated_after_created?
      created_at && updated_at && ((updated_at - created_at) > 1.hour)
    end
  end
end
