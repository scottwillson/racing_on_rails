module Caching
  extend ActiveSupport::Concern

  included do
    def self.expire_cache
      ActiveSupport::Notifications.instrument "expire_cache.racing_on_rails", perform_caching: perform_caching do
        RacingAssociation.current.touch
      end

      true
    end
  end


  protected

  def expire_cache
    self.class.expire_cache
  end
end
