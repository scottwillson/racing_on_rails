module Competitions
  class BlindDateAtTheDairyMonthlyStandings < Competition
    def self.parent_event_name
      "Blind Date at the Dairy"
    end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::Series.year(year).where(name: parent_event_name).first

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
      [ 0, 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    # source_results must be in person-order
    def source_results(race)
      return [] if source_events.empty?

      event_ids = source_events.map(&:id).join(', ')
      category_ids = category_ids_for(race).join(', ')

      Result.find_by_sql(
        %Q{ SELECT results.* FROM results
            JOIN races ON races.id = results.race_id
            JOIN categories ON categories.id = races.category_id
            JOIN events ON races.event_id = events.id
            WHERE place between 1 and #{point_schedule.size - 1}
                and categories.id in (#{category_ids})
                and events.id in (#{event_ids})
            order by person_id
         }
      )
    end

    # If same rider places twice in same race, only highest result counts
    def create_competition_results_for(results, race)
      competition_result = nil
      results.each_with_index do |source_result, index|
        logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

        person = source_result.person
        points = points_for(source_result)

        # We repeat some calculations here if a person is disallowed
        if points > 0.0 &&
           (!parent.completed? || (parent.completed? && raced_minimum_events?(person, race))) &&
             (!members_only? || member?(person, source_result.date))

          if first_result_for_person?(source_result, competition_result)
            # Intentionally not using results association create method. No need to hang on to all competition results.
            # In fact, this could cause serious memory issues with the Ironman
            competition_result = Result.create!(
               person: person,
               team: (person ? person.team : nil),
               race: race)
          end

          competition_result.scores.create_if_best_result_for_race(
            source_result: source_result,
            competition_result: competition_result,
            points: points
          )
        end

        # Aggressive memory management. If competition has a race with many results,
        # the results array can become a large, uneeded, structure
        results[index] = nil
        if index > 0 && index % 1000 == 0
          logger.debug("GC start after record #{index}")
          GC.start
        end

      end
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

    def minimum_events
      nil
    end

    def maximum_events(race)
      nil
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