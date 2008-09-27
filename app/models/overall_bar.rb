class OverallBar < Competition

  # Expire BAR web pages from cache. Expires *all* BAR pages. Shouldn't be in the model, either
  # BarSweeper seems to fire, but does not expire pages?
  # FIXME Dupe from Bar
  def OverallBar.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar")
  end
  
  def expire_cache
    OverallBar.expire_cache
  end
  
  def points_for(scoring_result)
    301 - scoring_result.place.to_i
  end

  def source_results(race)
    Result.find(:all,
                :include => [:race, {:racer => :team}, :team, {:race => [{:standings => :event}, :category]}],
                :conditions => [%Q{events.type = 'Bar' 
                  and place between 1 and 300
                  and categories.id in (#{category_ids_for(race)})
                  and events.date >= '#{date.year}-01-01' 
                  and events.date <= '#{date.year}-12-31'}],
                :order => 'racer_id'
    )
  end

  # if racer has > 4 discipline results, those results are worth 50 points
  # E.g., racer had top-15 results in road, track, cyclocross, mountain bike, and criteriums
  # TODO Consolidate these three methods? Are they all needed?
  def after_create_competition_results_for(race)
    for result in race.results
      set_bonus_points_for_extra_disciplines(result.scores)
    end
  end

  # if racer has > 4 discipline results, those results are worth 50 points
  # E.g., racer had top-15 results in road, track, cyclocross, mountain bike, and criterium
  def set_bonus_points_for_extra_disciplines(scores)
    scores.sort! { |x, y| y.points.to_i <=> x.points.to_i }
    remove_duplicate_discipline_results(scores)
    if scores.size > 4
      for score in scores[4..(scores.size - 1)]
        score.update_attribute_with_validation_skipping(:points, 50)
      end
    end
  end

  # If racer scored in more than one category that maps to same overall category in a discipline, 
  # count only highest-placing category.
  # This typically happens for age-based categories like Masters and Juniors
  # Assume scores sorted in preferred order (usually by points descending)
  # For the Category 4/5 Overall BAR, if a racer has both a Cat 4 and Cat 5 result for the same discipline,
  # we only count the Cat 4 result
  def remove_duplicate_discipline_results(scores)
    cat_4 = Category.find_by_name("Category 4 Men")
    cat_5 = Category.find_by_name("Category 5 Men")
    scores_to_delete = []
    cat_4_disciplines = []

    scores.each do |score|
      race = score.source_result.race
      if race.category == cat_4 
        cat_4_disciplines << race.standings.discipline
      end
    end

    scores.each do |score|
      race = score.source_result.race
      if race.category == cat_5 && cat_4_disciplines.include?(race.standings.discipline)
        logger.debug("Cat 4 result already exists: #{race.standings.discipline} results for #{score.source_result.racer}: #{race.category.name}")
        scores_to_delete << score
      end
    end
    scores_to_delete.each { |score| scores.delete(score) }
    
    scores_to_delete = []
    disciplines = []
    scores.each do |score|
      if disciplines.include?(score.source_result.race.standings.discipline)
        logger.debug("Multiple #{score.source_result.race.standings.discipline} results for #{score.source_result.racer}: #{score.source_result.race.category.name}")
        scores_to_delete << score
      else
        disciplines << score.source_result.race.standings.discipline
      end
    end
    scores_to_delete.each { |score| scores.delete(score) }
  end

  def create_standings
    root_standings = standings.create(:event => self, :discipline => Discipline[:overall].name)
    for category_name in [
      'Senior Men', 'Category 3 Men', 'Category 4/5 Men',
      'Senior Women', 'Category 3 Women', 'Category 4 Women', 
      'Junior Men', 'Junior Women', 'Masters Men', 'Masters Women', 
      'Singlespeed/Fixed', 'Tandem']

      category = Category.find_or_create_by_name(category_name)
      root_standings.races.create(:category => category)
    end
  end

  def friendly_name
    'Overall BAR'
  end
end
