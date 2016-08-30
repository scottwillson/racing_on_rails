module Competitions
  class BlindDateAtTheDairyTeamCompetition < Competition
    include Competitions::BlindDateAtTheDairy::Common

    validates_presence_of :parent

    after_create :add_source_events

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

    def all_year?
      false
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

    def race_category_names
      [ "Team Competition" ]
    end

    def source_results_category_names
      if year < 2016
        [
          "Beginner Men",
          "Beginner Women",
          "Masters Men A 40+",
          "Masters Men B 40+",
          "Masters Men C 40+",
          "Masters Men 50+",
          "Masters Men 60+",
          "Men A",
          "Men B",
          "Men C",
          "Singlespeed",
          "Stampede",
          "Women A",
          "Women B",
          "Women C"
        ]
      else
        [
          "Category 1/2 Men",
          "Category 2/3 Men",
          "Category 3/4 Men",
          "Category 5 Men",
          "Masters Men 1/2 40+",
          "Masters Men 2/3 40+",
          "Masters Men 3/4 40+",
          "Masters Men 50+",
          "Masters Men 60+",
          "Singlespeed",
          "Stampede",
          "Women 1/2",
          "Women 3",
          "Women 4",
          "Women 5",
        ]
      end
    end

    def categories_for(race)
      Category.where(name: source_results_category_names)
    end
  end
end
