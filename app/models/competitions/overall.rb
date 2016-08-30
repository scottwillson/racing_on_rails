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

    def categories_for(race)
      result_categories_by_race[race.category]
    end

    def result_categories_by_race
      @result_categories_by_race ||= create_result_categories_by_race
    end

    def create_result_categories_by_race
      result_categories_by_race = Hash.new { |hash, race_category| hash[race_category] = [] }

      result_categories.each do |category|
         best_match = category.best_match_in(self)
         if best_match
           result_categories_by_race[best_match] << category
         end
       end

       debug_result_categories_by_race(result_categories_by_race) if logger.debug?

       result_categories_by_race
    end

    def result_categories
      Category.results_in_year(year).where("results.event_id" => source_events)
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


    private

    def debug_result_categories_by_race(result_categories_by_race)
      result_categories_by_race.each do |competition_category, source_results_categories|
        source_results_categories.sort_by(&:name).each do |category|
          logger.debug "result_categories_by_race for #{full_name} #{competition_category.name} #{category.name}"
        end
      end
    end
  end
end
