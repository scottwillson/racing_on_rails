module Competitions
  # Best All-around Rider Competition. Assigns points for each top-15 placing in major Disciplines: road, track, etc.
  # Calculates a BAR for each Discipline, and an Overall BAR that combines all the discipline BARs.
  # Also calculates a team BAR.
  # Recalculating the BAR at years-end can take nearly 30 minutes even on a fast server. Recalculation must be manually triggered.
  # This class implements a number of OBRA-specific rules and should be generalized and simplified.
  # The BAR categories and disciplines are all configured in the database. Race categories need to have a bar_category_id to
  # show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
  class Bar < Competition
    include Bars::Categories
    include Bars::Discipline
    include Bars::Points
    include Competitions::Calculations::CalculatorAdapter

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          year = year.to_i if year.is_a?(String)
          date = Date.new(year, 1, 1)

          overall_bar = OverallBar.find_or_create_for_year(year)
          overall_bar.set_date

          # Age Graded BAR, Team BAR and Overall BAR do their own calculations
          ::Discipline.find_all_bar.reject { |discipline|
            [ ::Discipline[:age_graded], ::Discipline[:overall], ::Discipline[:team] ].include?(discipline)
          }.each do |discipline|
            bar = Bar.where(date: date, discipline: discipline.name).first
            unless bar
              Bar.create!(
                parent: overall_bar,
                name: "#{year} #{discipline.name} BAR",
                date: date,
                discipline: discipline.name
              )
            end
          end

          Bar.where(date: date).each do |bar|
            bar.set_date
            bar.delete_races
            bar.create_races
            # Could bulk load all Event and Races at this point, but hardly seems to matter
            bar.calculate!
          end
        end
      end
      # Don't return the entire populated instance!
      true
    end

    def field_size_bonus?
      true
    end

    def source_event_types
      [ Event, SingleDayEvent, MultiDayEvent, Series, WeeklySeries, Competitions::BlindDateAtTheDairyMonthlyStandings, Competitions::TaborOverall, ]
    end

    def source_results_query(race)
      super.
      where(bar: true).
      where("races.category_id in (?)", category_ids_for(race)).
      where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by).
      where("events.discipline in (:disciplines)
            or (events.discipline is null and parents_events.discipline in (:disciplines))
            or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (:disciplines))",
            disciplines: disciplines_for(race))
    end

    def after_source_results(results)
      results.each do |result|
        result["multiplier"] = result["race_bar_points"] || result["event_bar_points"] || result["parent_bar_points"] || result["parent_parent_bar_points"]
      end
    end

    def category_names
      ::Discipline[discipline].bar_categories.map(&:name)
    end

    def friendly_name
      'BAR'
    end
  end
end
