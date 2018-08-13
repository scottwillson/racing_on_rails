# frozen_string_literal: true

module Competitions
  # Common superclass for Omniums and Series standings.
  class Overall < Competition
    validates :parent, presence: true
    after_create :add_source_events

    def self.parent_event_name
      name
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::MultiDayEvent.year(year).where(name: parent_event_name).first

          overall = parent&.overall
          if parent&.any_results_including_children?
            unless overall
              # parent.create_overall will create an instance of Overall, which is probably not what we want
              overall = create!(parent_id: parent.id, date: parent.date)
              parent.overall = overall
            end
            overall.set_date
            overall.delete_races
            overall.create_races
            overall.calculate!
          end
        end
      end
      true
    end

    def default_name
      "Series Overall"
    end

    def source_events?
      true
    end

    def after_source_results(results, _race)
      results.each do |result|
        result["multiplier"] = result["points_factor"] || 1
      end
    end

    # Only members can score points?
    def members_only?
      false
    end

    def categories_for(race)
      result_categories_by_race[race.category]
    end
  end
end
