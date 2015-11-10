module ExceptionNotification
  class Logging
    def self.track_exception(e)
      Rails.logger.error e
      if e.respond_to?(:backtrace) && e.backtrace
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
end
