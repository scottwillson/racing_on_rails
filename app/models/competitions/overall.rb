module Competitions
  # Common superclass for Omniums and Series standings.
  class Overall < Competition
   validates_presence_of :parent
   after_create :add_source_events

   def self.parent_event_name
     self.name
   end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::MultiDayEvent.year(year).where(name: parent_event_name).first

          overall = parent.try(:overall)
          if parent && parent.any_results_including_children?
            if !overall
              # parent.create_overall will create an instance of Overall, which is probably not what we want
              overall = self.create!(parent_id: parent.id, date: parent.date)
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

    def source_results_query(race)
      super
        .where("ages_begin = ? and ages_end = ?", race.category.ages_begin, race.category.ages_end)
        .where("ability_begin = ? and ability_end = ?", race.category.ability_begin, race.category.ability_end)
        .where("categories.gender" => race.category.gender)
        .where("categories.equipment" => race.category.equipment)
    end

    def after_source_results(results, race)
      results.each do |result|
        result["multiplier"] = result["points_factor"] || 1
      end
    end

    # Only members can score points?
    def members_only?
      false
    end
  end
end
