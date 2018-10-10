# frozen_string_literal: true

module Competitions
  # Source events' categories don't match competition's categories.
  # Some need to be split: Junior Men 10-18 to Junior Men 10-12, Junior Men 13-14, etc.
  # Some need to be combined: Masters Men 30-34 and Masters Men 35-39 to Masters Men 30-39
  # Both splitting and combining add races to the source events before calculation
  module Races
    extend ActiveSupport::Concern

    def before_calculate
      races_created_for_competition.reject(&:visible?).each do |race|
        puts "destroy #{race.name}"
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

    # Split or combined races created only to calculate the competition
    def races_created_for_competition
      puts self.class
      source_events.map do |event|
        # event.races.each {|r| puts "#{event.name} #{r.name} #{r.created_by}"}
        event.races.select { |r| r.created_by.is_a?(self.class) }
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
              race.category.ability_begin >= category.ability_begin &&
              race.category.ability_end <= category.ability_end
              race.any_results?
          end
        end
    end

    def split_races(event, competition_category)
      races_to_split = select_races_to_split(event, competition_category)
      return if races_to_split.blank?

      existing_race = event.races.detect { |r| r.category == competition_category }
      race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updater: self, visible: false)

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
          r.category.gender        == competition_category.gender &&
          r.category.ages          != competition_category.ages &&
          r.category.ages_begin    <= competition_category.ages_begin &&
          r.category.ages_end      >= competition_category.ages_end &&
          r.category.ability_begin <= competition_category.ability_begin &&
          r.category.ability_end   >= competition_category.ability_end
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
        race = existing_race || event.races.create!(category: competition_category, bar_points: 0, updater: self, visible: false)

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
          ) &&
          r.category.ability_begin <= competition_category.ability_begin &&
          r.category.ability_end   >= competition_category.ability_end
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
      .each { |result| puts "combine #{race_to_combine.name} #{race.name} #{competition_category.name} #{result.name}" }
      .each { |result| create_result(race, result) }
    end

    def split?(competition_category, result)
      x = result.person&.racing_age &&
        competition_category.ages.include?(result.person.racing_age(year)) &&
        result.time &&
        result.time > 0

      if x
        puts "split? #{competition_category.name} #{result.name}"
      end

      x
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
      puts "create_result(#{race.name}, #{result.name})"
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
