module Competitions
  # OBRA OverallBar organized by Masters and Juniors age categories
  class AgeGradedBar < Competition
    after_create :set_parent

    def source_results_query(race)
      super.
      where("races.category_id" => race.category.parent_id).
      where("people.date_of_birth between ? and ?", race.dates_of_birth.begin, race.dates_of_birth.end)
    end

    def source_event_types
      [ Competitions::OverallBar ]
    end

    def category_names
      categories!.map(&:name)
    end

    def categories!
      categories = []
      template_categories.each do |template_category|
        unless Category.where(name: template_category.name).exists?
          template_category.save!
        end
        categories << template_category
      end

      categories
    end

    def template_categories
      masters_men = Category.find_or_create_by!(name: "Masters Men")
      masters_women = Category.find_or_create_by!(name: "Masters Women")
      junior_men = Category.find_or_create_by!(name: "Junior Men")
      junior_women = Category.find_or_create_by!(name: "Junior Women")

      template_categories = []
      position = 0
      30.step(65, 5) do |age|
        template_categories << Category.new(name: "Masters Men #{age}-#{age + 4}", ages: (age)..(age + 4), position: position = position.next, parent: masters_men)
      end
      template_categories << Category.new(name: 'Masters Men 70+', ages: 70..999, position: position = position.next, parent: masters_men)

      30.step(55, 5) do |age|
        template_categories << Category.new(name: "Masters Women #{age}-#{age + 4}", ages: (age)..(age + 4), position: position = position.next, parent: masters_women)
      end
      template_categories << Category.new(name: 'Masters Women 60+', ages: 60..999, position: position = position.next, parent: masters_women)

      template_categories << Category.new(name: "Junior Men 10-12", ages: 10..12, position: position = position.next, parent: junior_men)
      template_categories << Category.new(name: "Junior Men 13-14", ages: 13..14, position: position = position.next, parent: junior_men)
      template_categories << Category.new(name: "Junior Men 15-16", ages: 15..16, position: position = position.next, parent: junior_men)
      template_categories << Category.new(name: "Junior Men 17-18", ages: 17..18, position: position = position.next, parent: junior_men)

      template_categories << Category.new(name: "Junior Women 10-12", ages: 10..12, position: position = position.next, parent: junior_women)
      template_categories << Category.new(name: "Junior Women 13-14", ages: 13..14, position: position = position.next, parent: junior_women)
      template_categories << Category.new(name: "Junior Women 15-16", ages: 15..16, position: position = position.next, parent: junior_women)
      template_categories << Category.new(name: "Junior Women 17-18", ages: 17..18, position: position = position.next, parent: junior_women)
      template_categories
    end

    def set_parent
      if parent.nil?
        self.parent = OverallBar.find_or_create_for_year(year)
        save!
      end
    end

    def after_source_results(results)
      # BAR Results with the same place are always ties, and never team results
      set_team_size_to_one results
    end

    def default_discipline
      "Age Graded"
    end

    def friendly_name
      "Age Graded BAR"
    end

    def use_source_result_points?
      true
    end
  end
end
