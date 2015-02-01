require File.expand_path("../../../test_case", __FILE__)
require File.expand_path("../../../../../app/models/competitions/categories", __FILE__)

module Competitions
  # :stopdoc:
  class CategoriesTest < Ruby::TestCase
    def test_categories_for
      category = stub("Sandbaggers", name: "Sandbaggers", id: 2, descendants: [])
      competition = stub("Competition").extend(::Competitions::Categories)
      race = stub("race", category: category, category_id: 2)
      assert_equal([ category ], competition.categories_for(race), "category should include itself only")
    end

    def test_categories_for_descendants
      men_a = stub("Men A", name: "Men A", id: 1, descendants: [ ])
      category = stub("Senior Men", name: "Senior Men", id: 2, descendants: [ men_a ])
      competition = stub("Competition").extend(::Competitions::Categories)
      race = stub("race", category: category, category_id: 2)
      assert_same_elements([ men_a, category ], competition.categories_for(race), "category should include itself and descendant")
    end
  end
end
