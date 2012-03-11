module Concerns
  module Versioned
    extend ActiveSupport::Concern
    
    included do
      versioned :except => [ :current_login_at, :current_login_ip, :last_login_at, :last_login_ip, :login_count, :password_salt, 
                             :perishable_token, :persistence_token, :single_access_token ],
                :initial_version => true
      before_save :set_updater
    end

    def created_by
      versions.first.try :user
    end

    def updated_by
      versions.last.try :user
    end

    def set_updater
      self.updater ||= Person.current
      true
    end

    def created_from_result?
      created_by.present? && created_by.kind_of?(::Event)
    end
      
    def updated_after_created?
      created_at && updated_at && ((updated_at - created_at) > 1.hour)
    end
  end
end
