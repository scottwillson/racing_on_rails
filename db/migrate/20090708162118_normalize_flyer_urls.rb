# Clean up old OBRA flyers so we can simplify Event#flyer code
class NormalizeFlyerUrls < ActiveRecord::Migration
  def self.up
    Event.find.all().each do |event|
      if event.flyer
        event.flyer = event.flyer.gsub(/^..\/..\//, "http://#{STATIC_HOST}/")
        event.flyer = event.flyer.gsub(/^flyers/, "http://#{STATIC_HOST}/flyers")
        if event.flyer_changed?
          say event.flyer
          event.disable_notification!
          event.save!
          event.enable_notification!
        end
      end
    end
  end
end
