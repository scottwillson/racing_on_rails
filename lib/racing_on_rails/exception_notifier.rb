module RacingOnRails
  class ExceptionNotifier
    def self.track_exception(e)
      Rails.logger.error e
    end
  end
end
