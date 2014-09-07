module Competitions
  # Team's top ten results for each Event. Last-place points penalty if team has fewer than ten finishers.
  class CrossCrusadeTeamCompetition < Competition
    validates_presence_of :parent
    after_create :add_source_events
    before_create :set_notes, :set_name

    def self.calculate!(year = Time.zone.today.year)
      benchmark("#{name} calculate!", level: :info) {
        transaction do
          series = Series.where(name: "Cross Crusade").year(year).first

          if series && series.any_results_including_children?
            team_competition = series.child_competitions.detect { |c| c.is_a? CrossCrusadeTeamCompetition }
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
      }
      true
    end

    def create_races
      races.create!(category: Category.find_or_create_by(name: "Team"), result_columns: %W{ place team_name points })
    end

    def add_source_events
      parent.children.each do |source_event|
        source_events << source_event
      end
    end

    def source_results_with_benchmark(race)
      results = []
      Overall.benchmark("#{self.class.name} source_results", level: :debug) {
        results = source_results(race)
      }
      logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
      results
    end

    # source_results must be in team-order
    def source_results(race)
      return [] if parent.children.empty?

      event_ids = parent.children.map(&:id)

      Result.
        includes(race: :event).
        where("results.team_id is not null").
        where("events.id" => event_ids).
        references(:events).
        order("results.team_id")
    end

    def create_competition_results_for(results, race)
      competition_result = nil
      results.each do |source_result|
        team = source_result.team
        if team.member?
          unless competition_result && competition_result.team == team
            competition_result = Result.create!(team: team, race: race)
          end

          competition_result.scores.create!(
            source_result: source_result,
            competition_result: competition_result,
            points: points_for(source_result)
          )
        end
      end
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

    def minimum_events
      nil
    end

    def ascending_points?
      false
    end

    def points_for(source_result)
      place = source_result.place.to_i
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
