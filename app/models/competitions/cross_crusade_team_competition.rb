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

    def source_results_category_names
      CrossCrusadeOverall.new.category_names
    end

    def source_results_query(race)
      super.
      where("races.category_id" => category_ids_for(race))
    end
    
    def category_ids_for(race)
      super(race) - Category.where(name: [ "Junior Men", "Junior Women" ]).pluck(&:id)
    end

    def after_create_competition_results_for(race)
      source_events.select(&:any_results?).each do |source_event|
        race.results.each do |competition_result|
          scores_for_event_count = Competitions::Score.
            includes(source_result: { race: :event }).
            where(competition_result_id: competition_result.id, "events.id" => source_event.id).
            count

          case scores_for_event_count
          when 0
            competition_result.scores.create!(
              points: 1_000,
              competition_result: competition_result,
              source_result: competition_result,
              event_name: source_event.full_name,
              description: "Absentee Warriors",
              date: source_event.date
            )
          when 1..10
            competition_result.scores.create!(
              points: 100 * (10 - scores_for_event_count),
              competition_result: competition_result,
              source_result: competition_result,
              event_name: source_event.full_name,
              description: "Absentee Warriors",
              date: source_event.date
            )
          else
            scores_for_event = competition_result.scores.select { |s| s.source_result.event == source_event }
            lowest_scores = scores_for_event.sort_by(&:points)[10, scores_for_event.count - 10]
            lowest_scores.each do |lowest_score|
              competition_result.scores.destroy lowest_score
            end
            # Rails destroys Score in database, but doesn't update the current association
            competition_result.scores true
          end
        end
      end
    end

    # Member teams, people
    def members_only?
      false
    end

    def ascending_points?
      false
    end

    def points_for(source_result)
      place = source_result.numeric_place
      if place > 0 && place < 100
        place
      else
        100
      end
    end

    def set_notes
      self.notes = %Q{ In accordance with the Geneva Conventions, the official teams of the Cross Crusade have entered into a State of War for domination of the realm. <a href="http://crosscrusade.com/series.html" class="obvious">rules of engagement</a>. }
    end

    def set_name
      self.name = "Team Competition"
    end

    def all_year?
      false
    end
  end
end
