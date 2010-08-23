module RacingOnRails
  # Custom VestalVersion::Version that sets +user+
  class Version < VestalVersions::Version
    before_save :set_user
    
    def set_user
      unless user.present?
        self.user = Person.current
      end
    end
  end
end
