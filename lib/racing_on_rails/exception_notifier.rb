module RacingOnRails
  class ExceptionNotifier
    def self.notify(e)
      Rails.logger.error e
    end
  end
end
