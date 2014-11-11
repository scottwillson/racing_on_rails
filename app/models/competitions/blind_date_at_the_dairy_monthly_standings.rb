module Competitions
  class BlindDateAtTheDairyMonthlyStandings < Competition
    include Competitions::Calculations::CalculatorAdapter

    def self.parent_event_name
      "Blind Date at the Dairy"
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::WeeklySeries.year(year).where(name: parent_event_name).first

          if parent && parent.any_results_including_children?
            [ 9, 10 ].each do |month|
              month_name = Date::MONTHNAMES[month]
              standings = BlindDateAtTheDairyMonthlyStandings.find_or_create_by!(
                parent: parent,
                name: "#{month_name} Standings"
              )
              standings.date = Date.new(year, month)
              if standings.source_events.none?
                standings.add_source_events
              end
              standings.set_date
              standings.save!
              standings.destroy_races
              standings.create_races
              standings.calculate!
            end
          end
        end
      end
      true
    end

    def category_names
      [
        "Junior Men 10-13",
        "Junior Men 14-18",
        "Junior Women 10-13",
        "Junior Women 14-18",
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

    def default_bar_points
      1
    end

    def point_schedule
      [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def source_results_query(race)
      super.
      where("races.category_id in (?)", category_ids_for(race)).
      where("results.event_id" => source_events)
    end

    def add_source_events
      parent.children.select { |c| c.date.month == date.month }.each do |source_event|
        source_events << source_event
      end
    end

    # Only members can score points?
    def members_only?
      false
    end

    def default_bar_points
      1
    end

    def raced_minimum_events?(person, race)
      true
    end

    def preliminary?(result)
      false
    end

    def all_year?
      false
    end
  end
end