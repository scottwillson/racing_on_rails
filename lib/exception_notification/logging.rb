module ExceptionNotification
  class Logging
    def self.track_exception(e)
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
