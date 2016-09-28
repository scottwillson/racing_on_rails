module Competitions
  class BlindDateAtTheDairyMonthlyStandings < Competition
    include Competitions::BlindDateAtTheDairy::Common

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
              standings.delete_races
              standings.create_races
              standings.calculate!
            end
          end
        end
      end
      true
    end

    def categories_for(race)
      result_categories_by_race[race.category]
    end

    def add_source_events
      parent.children.select { |c| c.date.month == date.month }.each do |source_event|
        source_events << source_event
      end
    end

    def default_bar_points
      1
    end

    def source_events?
      true
    end
  end
end
