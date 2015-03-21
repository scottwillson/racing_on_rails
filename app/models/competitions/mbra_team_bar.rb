module Competitions
  # MBRA BAT scoring rules: http://www.montanacycling.net/documents/racers/MBRA%20BAR-BAT.pdf
  class MbraTeamBar < Competition
    include Bars::Discipline

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          year = year.to_i if year.is_a?(String)
          date = Date.new(year, 1, 1)

          ::Discipline.find_all_bar.each do |discipline|
            bar = MbraTeamBar.where(date: date, discipline: discipline.name).first
            unless bar
              MbraTeamBar.create!(
                name: "#{year} #{discipline.name} BAT",
                date: date,
                discipline: discipline.name
              )
            end
          end

          MbraTeamBar.where(date: date).each do |bar|
            bar.set_date
            bar.delete_races
            bar.create_races
            bar.calculate!
          end
        end
      end

      # Don't return the entire populated instance!
      true
    end

    # Event with bar points of zero aren't counted. But no bonus/multiplier even if event BAR points are set to 2 or 3.
    def after_source_results(results, race)
      results.each do |result|
        bar_points = result["race_bar_points"] || result["event_bar_points"] || result["parent_bar_points"] || result["parent_parent_bar_points"]
        if bar_points.nil? || bar_points >= 1
          result["multiplier"] = 1
        else
          result["multiplier"] = 0
        end
      end

      teams_who_promote_events = Event.year(year).select(:team_id).where.not(team_id: nil).uniq.pluck(:team_id)
      results.select do |result|
        result["participant_id"] &&
        result["participant_id"].in?(teams_who_promote_events)
      end
    end

    def source_results_query(race)
      super.
      where(bar: true).
      where("races.category_id" => categories_for(race)).
      where("events.discipline in (:disciplines)
            or (events.discipline is null and parents_events.discipline in (:disciplines))
            or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (:disciplines))",
            disciplines: disciplines_for(race))
    end

    def category_names
      ::Discipline[discipline].bar_categories.map(&:name)
    end

    def dnf_points
      0.5
    end

    def members_only?
      true
    end

    def place_bonus
      [ 6, 3, 1 ]
    end

    def points_schedule_from_field_size?
      true
    end

    def results_per_race
      2
    end

    def team?
      true
    end

    def dnf_points
      0.5
    end

    def place_bonus
      [ 6, 3, 1 ]
    end

    def points_schedule_from_field_size?
      true
    end

    def friendly_name
      'MBRA BAT'
    end
  end
end