class CleanUpOldVersions < ActiveRecord::Migration
  def remove_old_attributes(version)
    modifications = version.modifications

    case version.versioned_type
    when "DiscountCode"
      modifications.delete("status")
      modifications.delete("use_for")
      version.update! modifications: modifications
    when "Event", "SingleDayEvent", "MultidayEvent", "Series", "WeeklySeries"
      modifications.delete("notification")
      modifications.delete("lock_version")
      version.update! modifications: modifications
    when "RaceNumber", "Team"
      modifications.delete("lock_version")
      version.update! modifications: modifications
    when "Person"
      modifications.delete("card_type")
      modifications.delete("created_by_id")
      modifications.delete("fullname")
      modifications.delete("created_by_type")
      modifications.delete("last_updated_by")
      version.update! modifications: modifications
    when "Refund"
      modifications.delete("order_id")
      version.update! modifications: modifications
    end
  end

  def change
    VestalVersions::Version.transaction do
      VestalVersions::Version.where(versioned_type: "Page").destroy_all

      count = VestalVersions::Version.count
      index = 0
      VestalVersions::Version.find_each do |version|
        index += 1
        puts("#{index}/#{count}") if index % 1000 == 0
        remove_old_attributes version
      end
    end
  end
end
