module Caching
  extend ActiveSupport::Concern

  included do
    def self.expire_cache
      ActiveSupport::Notifications.instrument "expire_cache.racing_on_rails"
      begin
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "bar"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "cat4_womens_race_series"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "competitions"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "events"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "people"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "m"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "rider_rankings"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "results"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "schedule"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "teams"))
        FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "wsba_barr"))
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "bar.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "cat4_womens_race_series.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "home.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "index.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "m.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "owps.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "oregon_tt_cup.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "results.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "rider_rankings.html"), force: true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.html"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.ics"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.atom"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.xls"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "teams.html"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "wsba_barr.html"), force:true)
        FileUtils.rm(File.join(::Rails.root.to_s, "public", "wsba_masters_barr.html"), force:true)
      rescue StandardError => e
        logger.error e
      end

      true
    end
  end


  protected

  def expire_cache
    if perform_caching
      self.expire_cache
    end
  end
end
