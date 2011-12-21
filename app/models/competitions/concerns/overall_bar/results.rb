module Concerns
  module OverallBar
    module Results
      extend ActiveSupport::Concern

      def source_results(race)
        ::Result.all(
                    :include => [:race, {:person => :team}, :team, {:race => [:event, :category]}],
                    :conditions => [%Q{events.type = 'Bar' 
                      and place between 1 and 300
                      and ((events.discipline not in ("Mountain Bike", "Downhill", "Short Track") and categories.id in (#{category_ids_for(race)}))
                        or ((events.discipline in ("Mountain Bike", "Downhill", "Short Track")) and categories.id in (#{mtb_category_ids_for(race)})))
                      and events.date >= '#{date.year}-01-01' 
                      and events.date <= '#{date.year}-12-31'}],
                    :order => 'person_id'
        )
      end

      # Array of ids (integers)
      # +race+ category, +race+ category's siblings, and any competition categories
      # Overall BAR does some awesome mappings for MTB and DH
      def mtb_category_ids_for(race)
        return "NULL" unless race.category

        case race.category.name
        when "Senior Men"
          categories = [::Category.find_or_create_by_name("Pro Men")]
        when "Senior Women"
          categories = [::Category.find_or_create_by_name("Pro Women"), ::Category.find_or_create_by_name("Category 1 Women")]
        when "Category 3 Men"
          categories = [::Category.find_or_create_by_name("Category 1 Men")]
        when "Category 3 Women"
          categories = [::Category.find_or_create_by_name("Category 2 Women")]
        when "Category 4/5 Men"
          categories = [::Category.find_or_create_by_name("Category 2 Men"), ::Category.find_or_create_by_name("Category 3 Men")]
        when "Category 4 Women"
          categories = [::Category.find_or_create_by_name("Category 3 Women")]
        else
          categories = [race.category]      
        end

        categories.map(&:id).join ", "
      end

      # Only count the top 5 disciplines
      def after_create_competition_results_for(race)
        race.results.each do |result|
          result.scores.sort! { |x, y| y.points <=> x.points }
          remove_duplicate_discipline_results result.scores

          if result.scores.size > 5
            lowest_scores = result.scores[5, result.scores.size - 5]
            lowest_scores.each do |lowest_score|
              result.scores.destroy lowest_score
            end
            # Rails destroys Score in database, but doesn't update the current association
            result.scores true
          end
        end
      end

      # If person scored in more than one category that maps to same overall category in a discipline, 
      # count only highest-placing category.
      # This typically happens for age-based categories like Masters and Juniors
      # Assume scores sorted in preferred order (usually by points descending)
      # For the Category 4/5 Overall BAR, if a person has both a Cat 4 and Cat 5 result for the same discipline,
      # we only count the Cat 4 result
      def remove_duplicate_discipline_results(scores)
        cat_4 = find_category("Category 4 Men")
        cat_5 = find_category("Category 5 Men")
        scores_to_delete = []
        cat_4_disciplines = []

        scores.each do |score|
          race = score.source_result.race
          if race.category == cat_4 
            cat_4_disciplines << race.discipline
          end
        end

        scores.each do |score|
          race = score.source_result.race
          if race.category == cat_5 && cat_4_disciplines.include?(race.discipline)
            logger.debug("Cat 4 result already exists: #{race.discipline} results for #{score.source_result.person}: #{race.category.name}") if logger.debug?
            scores_to_delete << score
          end
        end
        scores_to_delete.each { |score| scores.delete(score) }

        scores_to_delete = []
        disciplines = []
        scores.each do |score|
          if disciplines.include?(score.source_discipline)
            logger.debug("Multiple #{score.source_discipline} results for #{score.source_result.person}: #{score.source_result.race.category.name}") if logger.debug?
            scores_to_delete << score
          else
            disciplines << score.source_discipline
          end
        end
        scores_to_delete.each { |score| scores.delete(score) }
      end
    end
  end
end
