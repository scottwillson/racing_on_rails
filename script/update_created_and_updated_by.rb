# frozen_string_literal: true

def versions_query
  VestalVersions::Version.where(versioned_type: "Page").destroy_all

  VestalVersions::Version
    .where(versioned_type: %w[
            DiscountCode
            Event
            MultidayEvent
            Person
            RaceNumber
            Refund
            Series
            SingleDayEvent
            Team
            WeeklySeries
         ])
end

puts
puts "Update created_by and updated_by PaperTrail"
[
  DiscountCode,
  Event,
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
  record_class
    .where(id: VestalVersions::Version.pluck(:versioned_id).uniq)
    .includes(:versions)
    .find_each do |record|

    index += 1
    puts("#{index}/#{count}") if index % 1000 == 0

    versions = record.versions.sort_by(&:created_at).select(&:user_id)
    next if versions.empty?

    record.update_columns(
      created_by_paper_trail_id: versions.first.user_id,
      created_by_paper_trail_type: versions.first.user_type,
      updated_by_paper_trail_id: versions.last.user_id,
      updated_by_paper_trail_type: versions.last.user_type
    )
  end
end
