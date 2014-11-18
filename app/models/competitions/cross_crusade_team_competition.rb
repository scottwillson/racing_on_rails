module Competitions
  # Team's top ten results for each Event. Last-place points penalty if team has fewer than ten finishers.
  class CrossCrusadeTeamCompetition < Competition
    include Competitions::Calculations::CalculatorAdapter

    validates_presence_of :parent
    after_create :add_source_events
    before_create :set_notes, :set_name

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          series = Series.where(name: "Cross Crusade").year(year).first

          if series && series.any_results_including_children?
            team_competition = series.child_competitions.detect { |c| c.is_a? CrossCrusadeTeamCompetition }
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
      true
    end

    def race_category_names
      [ "Team" ]
    end

    def category_names
      [
        "Athena",
        "Beginner Men",
        "Beginner Women",
        "Category A",
        "Category B",
        "Category C",
        "Clydesdale",
        "Junior Men",
        "Junior Women",
        "Masters 35+ A",
        "Masters 35+ B",
        "Masters 35+ C",
        "Masters 50+",
        "Masters 60+",
        "Masters Women 35+ A",
        "Masters Women 35+ B",
        "Masters Women 45+",
        "Singlespeed Women",
        "Singlespeed",
        "Unicycle",
        "Women A",
        "Women B",
        "Women C"
      ]
    end

    def source_results_query(race)
      super.
      where("results.race_name" => category_names)
    end

    def most_points_win?
      false
    end

    # Member teams, people
    def members_only?
      false
    end

    def break_ties?
      false
    end

    def point_schedule
      @point_schedule ||= (1..100).to_a
    end

    def set_notes
      self.notes = %Q{ In accordance with the Geneva Conventions, the official teams of the Cross Crusade have entered into a State of War for domination of the realm. <a href="http://crosscrusade.com/series.html" class="obvious">rules of engagement</a>. }
    end

    def set_name
      self.name = "Team Competition"
    end

    def source_events?
      true
    end

    def results_per_race
      Competition::UNLIMITED
    end

    def results_per_event
      10
    end

    def missing_result_penalty
      100
    end

    def team?
      true
    end
  end
end
