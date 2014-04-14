require File.expand_path("../../../test_case", __FILE__)
require File.expand_path("../../../../../app/models/competitions/categories", __FILE__)

module Competitions
  # :stopdoc:
  class CategoriesTest < Ruby::TestCase
    def test_category_ids_for
      category = stub("Sandbaggers", name: "Sandbaggers", id: 2, descendants: [])
      competition = stub("Competition").extend(::Competitions::Categories)
      race = stub("race", category: category, category_id: 2)
      assert_equal([ 2 ], competition.category_ids_for(race), "category should include itself only")
    end

    def test_category_ids_for_descendants
      men_a = stub("Men A", name: "Men A", id: 1, descendants: [ ])
      category = stub("Senior Men", name: "Senior Men", id: 2, descendants: [ men_a ])
      competition = stub("Competition").extend(::Competitions::Categories)
      race = stub("race", category: category, category_id: 2)
      assert_same_elements([ 1, 2 ], competition.category_ids_for(race), "category should include itself only")
    end
  end
end
