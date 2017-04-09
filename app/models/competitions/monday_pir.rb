# frozen_string_literal: true

module Competitions
  class MondayPir < Competition
    def self.parent_event_name
      "Monday Night PIR"
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::WeeklySeries.year(year).find_by(name: parent_event_name)

          if parent && parent.any_results_including_children?
            parent.children.map(&:date).map(&:month).uniq.sort.each do |month|
              month_name = Date::MONTHNAMES[month]
              standings = MondayPir.find_or_create_by!(
                parent: parent,
                name: "#{month_name} Standings"
              )
              standings.date = Date.new(year, month)
              standings.add_source_events if standings.source_events.none?
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

    def category_names
      [
        "Beginner",
        "Masters 30+ 1/2/3",
        "Masters 30+ 4/5",
        "Track/Fixed Gear",
        "Women 1/2/3",
        "Women 4/5"
      ]
    end

    def point_schedule
      event_points_schedule = {}

      source_events.each do |event|
        event_points_schedule[event.id] = [ 25, 18, 15, 12, 10, 8, 6, 4, 2, 1 ]
      end

      hot_spots.each do |event|
        event_points_schedule[event.id] = [ 6, 4, 2, 1 ]
      end

      event_points_schedule
    end

    def hot_spots
      source_events.map(&:children).flatten.select { |e| e.name[/hot/i] }
    end

    # Only members can score points?
    def members_only?
      false
    end
  end
end
