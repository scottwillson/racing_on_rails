module Competitions
  class BlindDateAtTheDairyTeamCompetition < Competition
    include Competitions::Calculations::CalculatorAdapter

    validates_presence_of :parent

    after_create :add_source_events

    def self.parent_event_name
      "Blind Date at the Dairy"
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          series = WeeklySeries.where(name: parent_event_name).year(year).first

          if series && series.any_results_including_children?
            team_competition = series.child_competitions.detect { |c| c.is_a? BlindDateAtTheDairyTeamCompetition }
            unless team_competition
              team_competition = self.new(parent_id: series.id)
              team_competition.save!
            end
            team_competition.set_date
            team_competition.destroy_races
            team_competition.create_races
            team_competition.calculate!
          end
        end
      end

      # Don't return the entire populated instance!
      true
    end

    def name
      "Team Competition"
    end

    def default_discipline
      "Cyclocross"
    end

    def team?
      true
    end

    def members_only?
      false
    end

    def all_year?
      false
    end

    def source_events?
      true
    end

    def default_bar_points
      0
    end

    def point_schedule
      [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def add_source_events
      parent.children.each do |source_event|
        if source_event.name == parent_event_name
          source_events << source_event
        end
      end
    end

    def source_results(race)
      query = Result.
        select([
          "bar",
          "1 as multiplier",
          "events.date",
          "events.ironman",
          "events.sanctioned_by",
          "events.type",
          "people.date_of_birth",
          "people.member_from",
          "people.member_to",
          "results.team_id as participant_id",
          "place",
          "points",
          "races.category_id",
          "race_id",
          "results.event_id",
          "results.id as id",
          "year"
        ]).
        joins(race: :event).
        joins("left outer join people on people.id = results.person_id").
        joins("left outer join events parents_events on parents_events.id = events.parent_id").
        joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
        where("races.category_id" => category_ids).
        where("place between 1 and ?", point_schedule.size).
        where("results.event_id" => source_event_ids(race))

      Result.connection.select_all query
    end

    def category_ids
      [
        "Beginner Men",
        "Beginner Women",
        "Masters Men A 40+",
        "Masters Men B 35+",
        "Masters Men C 35+",
        "Men A",
        "Men B",
        "Men C",
        "Singlespeed",
        "Stampede",
        "Women A",
        "Women B",
        "Women C"
      ].map do |category_name|
        Category.find_or_create_by_normalized_name(category_name)
      end
    end
  end
end
