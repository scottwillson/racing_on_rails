# frozen_string_literal: true

module Competitions
  # Year-long OBRA TT competition
  class OregonTTCup < Competition
    def friendly_name
      "OBRA Time Trial Cup"
    end

    def default_discipline
      "Time Trial"
    end

    def category_names
      [
        "Category 3 Men",
        "Category 3 Women",
        "Category 4/5 Men",
        "Category 4/5 Women",
        "Eddy Senior Men",
        "Eddy Senior Women",
        "Junior Men 10-12",
        "Junior Men 13-14",
        "Junior Men 15-16",
        "Junior Men 17-18",
        "Junior Women 10-14",
        "Junior Women 15-18",
        "Masters Men 30-39",
        "Masters Men 40-49",
        "Masters Men 50-59",
        "Masters Men 60-69",
        "Masters Men 70+",
        "Masters Women 30-39",
        "Masters Women 40-49",
        "Masters Women 50-59",
        "Masters Women 60-69",
        "Masters Women 70+",
        "Senior Men Pro/1/2",
        "Senior Women 1/2",
        "Tandem"
      ]
    end

    def point_schedule
      [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    def source_events?
      true
    end

    def maximum_events(_)
      8
    end

    def source_results_query(race)
      super
        .where(bar: true)
        .where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by)
    end

    def categories_for(race)
      ids = [race.category] + race.category.descendants

      case race.category.name
      when "Senior Men Pro/1/2"
        ["Men Category 1/2"]
      when "Category 4/5 Men"
        category_4_5_men_categories
      when "Senior Women 1/2"
        ["Senior Women", "Women Category 1/2"]
      when "Category 4/5 Women"
        ["Women Category 4", "Women Category 4/5"]
      when "Category 3 Women"
        ["Women Category 3"]
      when "Masters Men 40-49"
        ["Masters Men 40-49", "Men 160-199"]
      when "Masters Men 50-59"
        ["Masters Men 50-59", "Men 200-239"]
      when "Masters Men 60-69"
        ["Masters Men 60-69", "Men 240+"]
      when "Masters Women 50-59"
        ["Masters Women 50-59", "Women 200-239"]
      else
        []
      end.each do |name|
        category = Category.find_by(name: name)
        ids << category if category
      end

      ids
    end

    def category_4_5_men_categories
      [
        "Category 4 Men",
        "Category 4/5",
        "Category 5 Men",
        "Men 4/5",
        "Men Category 4",
        "Men Category 4/5"
      ]
    end

    def after_source_results(results, race)
      results.each do |result|
        result["team_size"] = 1
      end

      if race.name == "Tandem"
        beginning_of_year = Time.zone.local(year).beginning_of_year
        end_of_year = Time.zone.local(year).end_of_year

        results.each do |result|
          result["member_from"] = beginning_of_year
          result["member_to"] = end_of_year
        end
      end

      results
    end

    # Source events' categories don't match competition's categories.
    # Some need to be split: Junior Men 10-18 to Junior Men 10-12, Junior Men 13-14, etc.
    # Some need to be combined: Masters Men 30-34 and Masters Men 35-39 to Masters Men 30-39
    # Both splitting and combining add races to the source events before calculation
    def before_calculate
      races_created_for_competition.reject(&:visible?).each do |race|
        race.results.clear
        race.destroy
      end

      source_events(true).each do |source_event|
        missing_categories(source_event).each do |competition_category|
          logger.debug "Missing category for #{source_event.full_name}: #{competition_category.name}"
          split_races source_event, competition_category
          combine_races source_event, competition_category
        end
      end

      races.reload
      adjust_times
      races_created_for_competition.each(&:place_results_by_time)
      source_events.each(&:update_split_from!)
    end

    # Split or combined races created only to calculate the Oregon TT Cup
    def races_created_for_competition
      source_events.map do |event|
        event.races.select { |r| r.created_by.is_a?(Competitions::OregonTTCup) }
      end.flatten
    end

    # Find competition categories that should be in source events, but are not
    def missing_categories(source_event)
      category_names
        .map { |category_name| Category.find_by(name: category_name) }
        .select(&:age_group?)
        .select do |category|
          source_event.races.none? do |race|
            race.category.gender == category.gender &&
              race.category.ages == category.ages &&
              race.any_results?
          end
        end
    end

    def split_races(event, competition_category)
      races_to_split = select_races_to_split(event, competition_category)
      return if races_to_split.blank?

      existing_race = event.races.detect { |r| r.category == competition_category }
      race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updated_by: self, visible: false)

      races_to_split.each do |race_to_split|
        split_race competition_category, race_to_split, race
      end
    end

    def select_races_to_split(event, competition_category)
      (event.races + event.children.flat_map(&:races)).select do |r|
        r.any_results? &&
          r.category.age_group? &&
          competition_category.age_group? &&
          ((r.category.and_over? && competition_category.and_over?) ||
            (r.category.ages_end != ::Categories::MAXIMUM && competition_category.ages_end != ::Categories::MAXIMUM)) &&
          r.category.gender     == competition_category.gender &&
          r.category.ages       != competition_category.ages &&
          r.category.ages_begin <= competition_category.ages_begin &&
          r.category.ages_end   >= competition_category.ages_end
      end
    end

    def split_race(competition_category, race_to_split, race)
      race_to_split.results
                   .select { |result| split?(competition_category, result) }
                   .each { |result| create_result(race, result) }
    end

    def combine_races(event, competition_category)
      races_to_combine = select_races_to_combine(event.races + event.children.flat_map(&:races), competition_category)

      if races_to_combine.present?
        logger.debug "Combine races for #{event.full_name} #{competition_category.name}: #{races_to_combine.map(&:name).sort}"
        existing_race = event.races.detect { |r| r.category == competition_category }
        race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updated_by: self, visible: false)

        races_to_combine.each do |race_to_combine|
          combine_race race_to_combine, race, competition_category
        end
      end
    end

    def select_races_to_combine(races, competition_category)
      races.select do |r|
        r.any_results? &&
          r.category.age_group? &&
          competition_category.age_group? &&
          r.category.gender     == competition_category.gender &&
          r.category.ages       != competition_category.ages &&
          (
            (r.category.ages_begin >= competition_category.ages_begin && r.category.ages_end <= competition_category.ages_end) ||
            (r.category.ages_begin > competition_category.ages_begin &&
             r.category.ages_begin < competition_category.ages_end &&
             r.category.and_over?)
          )
      end
    end

    def combine_race(race_to_combine, race, competition_category)
      race_to_combine.results.select do |result|
        result.time &&
          result.time > 0 &&
          (result.person&.racing_age.nil? ||
            (result.person.racing_age(year) >= competition_category.ages_begin && result.person.racing_age(year) <= competition_category.ages_end)
          )
      end
                     .each { |result| create_result(race, result) }
    end

    def split?(competition_category, result)
      result.person&.racing_age &&
        competition_category.ages.include?(result.person.racing_age(year)) &&
        result.time &&
        result.time > 0
    end

    def adjust_times
      races_created_for_competition.each do |race|
        distances = race.results.map(&:distance).compact.select(&:positive?)
        next if distances.empty?
        max_distance = distances.max
        race.results.each do |result|
          if result.distance.nil? || result.distance == 0
            raise StandardError, "#{result.id} for #{result.race_full_name} #{result.event_full_name} does not have a distance"
          end

          new_time = result.time * (max_distance / result.distance) * 1.1
          result.update!(time: new_time)
        end
      end
    end

    def create_result(race, result)
      race.results.create!(
        distance: result.distance,
        place: result.place,
        person: result.person,
        team: result.team,
        time: result.time
      )
    end
  end
end
