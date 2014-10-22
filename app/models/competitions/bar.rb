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
    include Competitions::CalculatorAdapter

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

    def self.find_by_year_and_discipline(year, discipline_name)
      Bar.where(date: Time.zone.local(year).to_date, discipline: discipline_name).first
    end

    def point_schedule
      [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def field_size_bonus?
      true
    end

    # Source result = counts towards the BAR "race" and BAR results
    # Example: Piece of Cake RR, 6th, Jon Knowlson
    #
    # bar_result, bar_race = BAR itself and placing in the BAR
    # Example: Senior Men BAR, 130th, Jon Knowlson, 45 points
    #
    # BAR results add scoring results as scores
    # Example:
    # Senior Men BAR, 130th, Jon Knowlson, 18 points
    #  - Piece of Cake RR, 6th, Jon Knowlson 10 points
    #  - Silverton RR, 8th, Jon Knowlson 8 points

    # Results as array of hashes. Select fewest fields needed to calculate results.
    # Some competition rules applied here in the query and results excluded. It's a judgement call to apply them here
    # rather than in #calculate.
    def source_results(race)
      query = Result.
        select([
          "results.id as id", "person_id as participant_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date", "results.year",
          "coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) as multiplier"
        ]).
        joins(race: :event).
        joins("left outer join people on people.id = results.person_id").
        joins("left outer join events parents_events on parents_events.id = events.parent_id").
        joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
        where("place between 1 and ?", point_schedule.size).
        where("(events.type in (?) or events.type is NULL)", source_event_types).
        where(bar: true).
        where("races.category_id in (?)", category_ids_for(race)).
        where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by).
        where("events.discipline in (:disciplines)
              or (events.discipline is null and parents_events.discipline in (:disciplines))
              or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (:disciplines))",
              disciplines: disciplines_for(race)).
        where("coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) > 0").
        where("results.year = ?", year).
        references(:results, :events, :categories)

      Result.connection.select_all query
    end

    def source_event_types
      %w{ Event SingleDayEvent MultiDayEvent Series WeeklySeries Competitions::BlindDateAtTheDairyMonthlyStandings Competitions::TaborOverall }
    end

    def create_races
      ::Discipline[discipline].bar_categories.each do |category|
        races.create!(category: category)
      end
    end

    def friendly_name
      'BAR'
    end

    def to_s
      "#<#{self.class.name} #{id} #{discipline} #{name} #{date}>"
    end
  end
end
