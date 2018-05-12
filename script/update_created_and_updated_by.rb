def remove_old_attributes
  count = versions_query.count
  index = 0

  puts "Remove old attributes from versions"
  versions_query.find_each do |version|
    index = index + 1
    if index % 1000 == 0
      puts "#{index}/#{count}"
    end

    modifications = version.modifications

    case version.versioned_type
    when "DiscountCode"
      modifications.delete("status")
      modifications.delete("use_for")
      version.update_attributes! modifications: modifications
    when "Event", "SingleDayEvent", "MultidayEvent", "Series", "WeeklySeries"
      modifications.delete("notification")
      modifications.delete("lock_version")
      version.update_attributes! modifications: modifications
    when "Page", "RaceNumber", "Team"
      modifications.delete("lock_version")
      version.update_attributes! modifications: modifications
    when "Person"
      modifications.delete("card_type")
      modifications.delete("created_by_id")
      modifications.delete("fullname")
      modifications.delete("created_by_type")
      modifications.delete("last_updated_by")
      version.update_attributes! modifications: modifications
    when "Refund"
      modifications.delete("order_id")
      version.update_attributes! modifications: modifications
    end
  end
end

def versions_query
  VestalVersions::Version
    .where(versioned_type: %w[
            DiscountCode
            Event
            MultidayEvent
            Page
            Person
            RaceNumber
            Refund
            Series
            SingleDayEvent
            Team
            WeeklySeries
         ])
end

PaperTrailVersion.delete_all

PaperTrailVersion.transaction do
  remove_old_attributes

  puts
  puts "Copy versions to PaperTrail"
  [
    DiscountCode,
    Event,
    Page,
    Person,
    Race,
    RaceNumber,
    Refund,
    Team
  ].each do |record_class|
    count = record_class.count
    index = 0
    puts
    puts record_class
    record_class.where(id: VestalVersions::Version.pluck(:versioned_id)).find_each do |record|
      index += 1
      puts("#{index}/#{count}") if index % 1000 == 0

      versions = record.versions
      max_version = versions.size - 1

      (0..max_version).each do |version_index|
        begin
          version = versions[version_index]
          record.reload.revert_to version_index

          unless record.id
            puts "No ID for #{record_class} version #{version_index} version ID #{version.id}"
            next
          end

          attributes = record.attributes.dup
          attributes.delete(:card_type)
          attributes.delete(:created_by_id)
          attributes.delete(:created_by_type)
          attributes.delete(:fullname)
          attributes.delete(:last_updated_by)
          attributes.delete(:lock_version)
          attributes.delete(:notification)
          attributes.delete(:order_id)
          attributes.delete(:use_for)

          attributes.delete(:status) if record.is_a?(DiscountCode)

          PaperTrailVersion.create!(
            created_at: version.updated_at,
            event: version_index == 0 ? "create" : "update",
            item_type: version.versioned_type,
            item_id: record.id,
            object: attributes.to_yaml,
            object_changes: version.changes.to_yaml,
            whodunnit: record.updated_by_person_name
          )
        rescue ActiveModel::MissingAttributeError => e
          puts "#{e} for #{record_class} ID #{record.id} version #{version_index} version ID #{version.id}"
          pp attributes
          raise e
        rescue ActiveRecord::RecordNotFound => e
          puts "#{e} for #{record_class} ID #{record.id} version #{version_index} version ID #{version.id}"
          pp attributes
          next
        rescue StandardError => e
          puts "Could not migrate #{record_class} ID #{record.id} version #{version_index} version ID #{version.id}"
          pp version
          raise e
        end
      end
    end
  end
end
