module Competitions
  class BlindDateAtTheDairyTeamCompetition < Competition
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
            team_competition.delete_races
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

    def point_schedule
      [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def source_events?
      true
    end

    def add_source_events
      parent.children.each do |source_event|
        if source_event.name == parent_event_name
          source_events << source_event
        end
      end
    end

    def source_results_query(race)
      super.
      where("races.category_id" => categories_for(race))
    end

    def race_category_names
      [ "Team Competition" ]
    end

    def source_results_category_names
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
      ]
    end

    def categories_for(race)
      Category.where(name: source_results_category_names)
    end
  end
end
