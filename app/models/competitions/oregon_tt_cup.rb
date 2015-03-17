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
        "Masters Men 60+",
        "Masters Men 70+",
        "Masters Women 30-39",
        "Masters Women 40-49",
        "Masters Women 50-59",
        "Masters Women 60+",
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

    def maximum_events(race)
      8
    end

    def source_results_query(race)
      super.
      where(bar: true).
      where("races.category_id" => categories_for(race)).
      where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by)
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
        category = Category.where(name: name).first
        if category
          ids << category.id
        end
      end

      ids
    end

    # Source events' categories don't match competition's categories.
    # Some need to be split. For example: Junior Men 10-18 to Junior Men 10-12, Junior Men 13-14, etc.
    # Some need to combined: For example: Masters Men 30-34 and Masters Men 35-39 to Masters Men 30-39
    # Both splitting and combining add races to the source events before calculation
    def before_calculate
      destroy_or_tt_cup_races

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
        event.races.select { |r| r.created_by.kind_of?(OregonTTCup) }.
        each(&:destroy)
      end
    end

    # Find competition categories that should be in source events, but are not
    def missing_categories
      missing_categories = Hash.new { |hash, key| hash[key] = [] }
      source_events(true).each do |source_event|
        category_names.each do |category_name|
          category = Category.where(name: category_name).first
          if category.age_group?
            if source_event.races.none? do |race|
                race.category.gender == category.gender &&
                race.category.ages == category.ages
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

      if races_to_split.present?
        existing_race = event.races.detect { |r| r.category == competition_category }
        race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updated_by: self, visible: false)

        races_to_split.each do |race_to_split|
          split_race race_to_split, race, competition_category
        end

        race.place_results_by_time
      end
    end

    def select_races_to_split(event, competition_category)
      event.races.select do |r|
        r.category.age_group? &&
        competition_category.age_group? &&
        ((r.category.and_over? && competition_category.and_over?) || (r.category.ages_end != 999 && competition_category.ages_end != 99)) &&
        r.category.gender     == competition_category.gender &&
        r.category.ages       != competition_category.ages &&
        r.category.ages_begin <= competition_category.ages_begin &&
        r.category.ages_end   >= competition_category.ages_end
      end
    end

    def split_race(race_to_split, race, competition_category)
      race_to_split.results.select do |result|
        result.person &&
        result.person.racing_age &&
        competition_category.ages.include?(result.person.racing_age) &&
        result.time &&
        result.time > 0
      end.each do |result|
        race.results.create!(
          place: result.place,
          person: result.person,
          team: result.team,
          time: result.time,
        )
      end
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
        (result.person.racing_age.nil? || (result.person.racing_age >= competition_category.ages_begin && result.person.racing_age <= competition_category.ages_end))
      end.each do |result|
        time = result.time
        race.results.create!(
          place: result.place,
          person: result.person,
          team: result.team,
          time: time
        )
      end
    end
  end
end
