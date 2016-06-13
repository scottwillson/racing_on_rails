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
      [ 20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
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
        .where("races.category_id" => categories_for(race))
        .where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by)
    end

    def categories_for(race)
      ids = [ race.category ] + race.category.descendants

      case race.category.name
      when "Senior Men Pro/1/2"
        [ "Men Category 1/2" ]
      when "Senior Women 1/2"
        [ "Senior Women", "Women Category 1/2" ]
      when "Category 4/5 Women"
        [ "Women Category 4", "Women Category 4/5" ]
      when "Category 3 Women"
        [ "Women Category 3" ]
      else
        []
      end.each do |name|
        category = Category.find_by(name: name)
        if category
          ids << category.id
        end
      end

      ids
    end

    def after_source_results(results, race)
      if race.name == "Tandem"
        beginning_of_year = Time.zone.now.beginning_of_year
        end_of_year = Time.zone.now.end_of_year

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
      destroy_or_tt_cup_races
      set_distances

      missing_categories.each do |event, categories|
        categories.each do |competition_category|
          split_races event, competition_category
          combine_races event, competition_category
        end
      end
    end

    # Destroy races created just to calculate the Oregon TT Cup
    def destroy_or_tt_cup_races
      source_events.each do |event|
        event.races
          .select { |r| r.created_by.is_a?(OregonTTCup) }
          .each(&:destroy)
      end
    end

    # Ensure distance is set so times can be adjusted. Some categories with different
    # distances are combined.
    def set_distances
      source_events.reload.each do |event|
        event.races.each do |race|
          race.update_attributes!(distance: 12.4) if twenty_k?(race)
          race.update_attributes!(distance: 6.2) if ten_k?(race)
        end
      end
    end

    # Find competition categories that should be in source events, but are not
    def missing_categories
      missing_categories = Hash.new { |hash, key| hash[key] = [] }
      source_events.reload.each do |source_event|
        category_names.each do |category_name|
          category = Category.find_by(name: category_name)
          if category.age_group?
            if source_event.races.none? do |race|
                race.category.gender == category.gender &&
                race.category.ages == category.ages &&
                race.any_results?
              end
              missing_categories[source_event] = missing_categories[source_event] << category
            end
          end
        end
      end

      missing_categories
    end

    def split_races(event, competition_category)
      races_to_split = select_races_to_split(event, competition_category)
      return unless races_to_split.present?

      existing_race = event.races.detect { |r| r.category == competition_category }
      race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updated_by: self, visible: false)

      races_to_split.each do |race_to_split|
        split_race competition_category, race_to_split, race
      end

      race.place_results_by_time
    end

    def select_races_to_split(event, competition_category)
      event.races.select do |r|
        r.category.age_group? &&
        competition_category.age_group? &&
        ((r.category.and_over? && competition_category.and_over?) || (r.category.ages_end != Category::MAX && competition_category.ages_end != Category::MAX)) &&
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
      races_to_combine = select_races_to_combine(event.races, competition_category)

      if races_to_combine.present?
        existing_race = event.races.detect { |r| r.category == competition_category }
        race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updated_by: self, visible: false)

        races_to_combine.each do |race_to_combine|
          combine_race race_to_combine, race, competition_category
        end
        race.place_results_by_time
      end
    end

    def select_races_to_combine(races, competition_category)
      races.select do |r|
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
          (result.person.racing_age >= competition_category.ages_begin && result.person.racing_age <= competition_category.ages_end)
        )
      end.each do |result|
        time = result.time
        if short?(result) && result.race.distance.present? && result.race.distance.to_f < 24.9
          time = result.time * 2.2
        end
        race.results.create!(
          place: result.place,
          person: result.person,
          team: result.team,
          time: time
        )
      end
    end

    def short?(event_or_result)
      if event_or_result.respond_to?(:event_id)
        event_or_result.event_id == 23543
      else
        event_or_result.id == 23543
      end
    end

    def ten_k?(race)
      short?(race) &&
      race.category.name.in?([
        "Junior Men 10-12",
        "Junior Men 13-14",
        "Junior Women 10-12",
        "Junior Women 13-14"
      ])
    end

    def twenty_k?(race)
      short?(race) &&
      race.category.name.in?([
        "Masters Men 65-69",
        "Masters Men 70+",
        "Masters Women 55-59",
        "Masters Women 60-64",
        "Masters Women 65-69"
      ])
    end

    def split?(competition_category, result)
      result.person &&
      result.person.racing_age &&
      competition_category.ages.include?(result.person.racing_age) &&
      result.time &&
      result.time > 0
    end

    def create_result(race, result)
      race.results.create!(
        place: result.place,
        person: result.person,
        team: result.team,
        time: result.time
      )
    end
  end
end
