module ExceptionNotification
  class Logging
    def self.track_exception(e)
      Rails.logger.error e
    end
  end
end
