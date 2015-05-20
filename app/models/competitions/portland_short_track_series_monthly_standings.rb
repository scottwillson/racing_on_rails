module Competitions
  class PortlandShortTrackSeriesMonthlyStandings < Competition
    def self.parent_event_name
      "Portland Short Track Series MTB STXC"
    end

    def category_names
      [
        "Category 1 Men 19-34",
        "Category 1 Men 35-44",
        "Category 1 Men 45+",
        "Category 2 Men 35-44",
        "Category 2 Men 45-54",
        "Category 2 Men 55+",
        "Category 2 Men U35",
        "Category 2 Women 35-44",
        "Category 2 Women 45+",
        "Category 2 Women U35",
        "Category 3 Men 10-14",
        "Category 3 Men 15-18",
        "Category 3 Men 19-44",
        "Category 3 Men 45+",
        "Category 3 Women 10-14",
        "Category 3 Women 15-18",
        "Category 3 Women 19+",
        "Clydesdale",
        "Elite Men",
        "Elite/Category 1 Women",
        "Singlespeed"
      ]
    end

    def point_schedule
      [ 100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::WeeklySeries.year(year).where(name: parent_event_name).first

          if parent && parent.any_results_including_children?
            [ 6, 7 ].each do |month|
              month_name = Date::MONTHNAMES[month]
              standings = PortlandShortTrackSeriesOverall.find_or_create_by!(
                parent: parent,
                name: "#{month_name} Standings"
              )
              standings.date = Date.new(year, month)
              if standings.source_events.none?
                standings.add_source_events
              end
              standings.set_date
              standings.save!
              standings.delete_races
              standings.create_races
              standings.calculate!
            end
          end
        end
      end
      true
    end

    def source_results_query(race)
      super.
      where("races.category_id" => categories_for(race))
    end

    def add_source_events
      parent.children.select { |c| c.date.month == date.month }.each do |source_event|
        source_events << source_event
      end
    end

    def source_events?
      true
    end
  end
end
