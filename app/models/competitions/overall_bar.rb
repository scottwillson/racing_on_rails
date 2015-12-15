module Competitions
  # See Bar class.
  class OverallBar < Competition
    include OverallBars::Categories
    # include OverallBars::Points
    include OverallBars::Races

    def create_children
      Discipline.find_all_bar.
      reject { |discipline| [Discipline[:age_graded], Discipline[:overall], Discipline[:team]].include?(discipline) }.
      each do |discipline|
        unless Bar.year(year).where(discipline: discipline.name).exists?
          Bar.create!(
            parent: self,
            name: "#{year} #{discipline.name} BAR",
            date: date,
            discipline: discipline.name
          )
        end
      end
    end

    def source_results_query(race)
      super.
      where("races.category_id" => categories_for(race))
    end

    def category_names
      [
        "Clydesdale",
        "Category 3 Men",
        "Category 3 Women",
        "Category 4 Women",
        "Category 4/5 Men",
        "Junior Men",
        "Junior Women",
        "Masters Men 4/5",
        "Masters Men",
        "Masters Women 4",
        "Masters Women",
        "Senior Men",
        "Senior Women",
        "Singlespeed/Fixed",
        "Tandem"
      ]
    end

    def source_event_types
      [ Competitions::Bar ]
    end

    def after_source_results(results, race)
      results = reject_duplicate_discipline_results(results)
      # BAR Results with the same place are always ties, and never team results
      set_team_size_to_one results
    end

    # If person scored in more than one category that maps to same overall category in a discipline,
    # count only highest-placing category.
    # This typically happens for age-based categories like Masters and Juniors
    # Assume scores sorted in preferred order (usually by points descending)
    # For the Category 4/5 Overall BAR, if a person has both a Cat 4 and Cat 5 result for the same discipline,
    # we only count the Cat 4 result
    def reject_duplicate_discipline_results(source_results)
      filtered_results = []

      source_results.group_by { |r| r["participant_id"] }.each do |participant_id, results|
        results.select { |r| r["category_name"] == "Category 4 Men"}.each do |cat_4_result|
          results = results.reject do |r|
            r["category_name"] == "Category 5 Men" && r["discipline"] == cat_4_result["discipline"]
          end
        end

        results.group_by { |r| r["discipline"] }.each do |discipline, discipline_results|
          filtered_results << discipline_results.sort_by { |r| r["points"].to_f }.reverse.first
        end
      end

      filtered_results
    end

    # 300 points for first place, 299 for second, etc.
    def point_schedule
      (1..300).to_a.reverse
    end

    def maximum_events(race)
      5
    end

    def friendly_name
      'Overall BAR'
    end

    def default_discipline
      "Overall"
    end
  end
end
