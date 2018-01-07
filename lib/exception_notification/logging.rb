# frozen_string_literal: true

module ExceptionNotification
  class Logging
    def self.track_exception(e)
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n") if e.respond_to?(:backtrace) && e.backtrace
    end
  end
end
