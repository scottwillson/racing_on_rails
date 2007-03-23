module Competitions
  class OverallBar < Competition
  def old_recalc
    # Create overall BAR results based on discipline results
    # overall BAR: Add results from discipline BAR races
    for bar_standings in standings
      if bar_standings.name != "Overall" and bar_standings.name != 'Team'
        for discipline_race in bar_standings.races
          for discipline_source_result in discipline_race.results.sort!
            logger.debug("BAR Overall scoring result: '#{discipline_source_result.race.standings.name}' #{discipline_source_result.race.category} #{discipline_source_result.place} #{discipline_source_result.last_name}") if logger.debug?
            if discipline_source_result.race.category and discipline_source_result.race.category.overall
              racer = discipline_source_result.racer
              progress_monitor.detail_text = "#{racer.first_name} #{racer.last_name}"
              bar_race = find_overall_race(discipline_source_result)
              overall_bar_result = bar_race.results.detect {|result| result.racer == racer}
              if overall_bar_result.nil?
                overall_bar_result = bar_race.results.create
                raise(RuntimeError, overall_bar_result.errors.full_messages) unless overall_bar_result.errors.empty?
                overall_bar_result.racer = racer
                overall_bar_result.team = discipline_source_result.team
                logger.debug("BAR Add new BAR result to #{bar_race.name} for #{racer.last_name}") if logger.debug?
                overall_bar_result.save!
              else
                logger.debug("BAR Existing BAR result. #{overall_bar_result.last_name} == #{racer.last_name}") if logger.debug?
              end
              overall_bar_result.scores.create_if_best_result_for_race(
                :source_result => discipline_source_result, 
                :competition_result => overall_bar_result, 
                :points => 301 - discipline_source_result.place.to_i
              )
              raise(RuntimeError, overall_bar_result.errors.full_messages) unless overall_bar_result.errors.empty?
              overall_bar_result.calculate_points
            else
              logger.warn("WARN: #{discipline_source_result.race.name} has no category")
            end
          end
        end
      end
    
      # if racer has > 4 discipline results, those results are worth 50 points
      overall_standings = standings.detect{|s| s.name == "Overall" }
      for race in overall_standings.races
        for result in race.results
          set_bonus_points_for_extra_disciplines(result.scores)
          result.calculate_points
        end
      end

      # sort overall
      for race in overall_standings.races
        race.results.sort! {|x, y| y.points <=> x.points}
      end
    end
  end

  # if racer has > 4 discipline results, those results are worth 50 points
  # E.g., racer had top-15 results in road, track, cyclocross, mountain bike, and criteriums
  def set_bonus_points_for_extra_disciplines(scores)
    scores.sort! {|x, y| y.points.to_i <=> x.points.to_i}
    remove_duplicate_discipline_results(scores)
    if scores.size > 4
      for score in scores[4..(scores.size - 1)]
        score.update_attribute_with_validation_skipping(:points, 50)
      end
    end
  end

  # If racer scored in more than one category that maps to same overall category in a discipline, count only highest-placing category
  # This typically happens for age-based categories like Masters and Juniors
  # Assume scores sorted by points descending
  def remove_duplicate_discipline_results(scores)
    disciplines = []
    scores.each do |score|
      if disciplines.include?(score.source_result.race.standings.discipline)
        logger.debug("Multiple #{score.source_result.race.standings.discipline} results for #{score.source_result.racer}")
        scores.delete(score)
      else
        disciplines << score.source_result.race.standings.discipline
      end
    end
  end
end