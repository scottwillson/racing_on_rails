module Results
  module Caching
    extend ActiveSupport::Concern

    included do
      before_save :cache_non_event_attributes
      before_create :cache_event_attributes
    end

    # Cache expensive cross-table lookups
    def cache_non_event_attributes
      self[:category_name] = category.try(:name)
      self[:first_name]    = person.try(:first_name, date)
      self[:last_name]     = person.try(:last_name, date)
      self[:name]          = person.try(:name, date)
      self[:team_name]     = team.try(:name, date)
      self[:team_member]   = team ? team.member_in_year?(date) : false
      true
    end

    def cache_event_attributes
      self[:competition_result]      = calculate_competition_result
      self[:date]                    = event.date
      self[:event_date_range_s]      = event.date_range_s
      self[:event_end_date]          = event.end_date
      self[:event_full_name]         = event.full_name
      self[:event_id]                = event.id
      self[:race_full_name]          = race.try(:full_name)
      self[:race_name]               = race.try(:name)
      self[:team_competition_result] = calculate_team_competition_result
      self.year                      = event.year
      true
    end

    def cache_attributes!(*args)
      args = args.extract_options!
      cache_event_attributes if args.include?(:event)
      cache_non_event_attributes if args.empty? || args.include?(:non_event)
      save!
    end

  end
end
