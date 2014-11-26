module Competitions
  # MBRA Best All-around Rider Competition.
  # Calculates a BAR for each Discipline
  # The BAR categories and disciplines are all configured in the databsase. Race categories need to have a bar_category_id to
  # show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
  #
  # MBRA BAR scoring rules: http://www.montanacycling.net/documents/racers/MBRA%20BAR-BAT.pdf
  class MbraBar < Competition
    include Bars::Discipline

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          year = year.to_i if year.is_a?(String)
          date = Date.new(year, 1, 1)

          # TODO switch to #create_children
          ::Discipline.find_all_bar.each do |discipline|
            bar = MbraBar.where(date: date, discipline: discipline.name).first
            unless bar
              MbraBar.create!(
                name: "#{year} #{discipline.name} BAR",
                date: date,
                discipline: discipline.name
              )
            end
          end

          MbraBar.where(date: date).each do |bar|
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

    def after_source_results(results)
      results.each do |result|
        result["multiplier"] = result["race_bar_points"] || result["event_bar_points"] || result["parent_bar_points"] || result["parent_parent_bar_points"]
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

    def maximum_events(race)
      (Event.find_all_bar_for_discipline(discipline, year).size * 0.7).round.to_i
    end

    def upgrades
      {
        "Category 4 Men"       => "Category 5 Men",
        "Category 3 Men"       => "Category 4 Men",
        "Category 1/2 Men"     => "Category 3 Men",
        "Category 1/2/3 Women" => "Category 4 Women"
      }
    end

    def category_names
      ::Discipline[discipline].bar_categories.map(&:name)
    end

    def maximum_upgrade_points
      30
    end

    def members_only?
      false
    end

    def place_bonus
      [ 6, 3, 1 ]
    end

    def dnf_points
      0.5
    end

    def points_schedule_from_field_size?
      true
    end

    def friendly_name
      'MBRA BAR'
    end
  end
end