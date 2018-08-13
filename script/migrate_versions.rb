# frozen_string_literal: true

puts "Copy versions to PaperTrail"

RacingOnRails::PaperTrail::Version.delete_all

[
  DiscountCode,
  Event,
  Person,
  Race,
  RaceNumber,
  Refund,
  Team
].each do |record_class|

  RacingOnRails::PaperTrail::Version.transaction do
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

          RacingOnRails::PaperTrail::Version.create!(
            created_at: version.updated_at,
            event: version_index == 0 ? "create" : "update",
            item_type: version.versioned_type,
            item_id: record.id,
            object: attributes.to_yaml,
            object_changes: version.modifications.to_yaml,
            whodunnit: version.user&.name
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
