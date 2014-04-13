require File.expand_path("../../../../../test_case", __FILE__)
require File.expand_path("../../../../../../../app/models/competitions/concerns/overall_bar/results", __FILE__)

# :stopdoc:
class Concerns::OverallBar::ResultsTest < Ruby::TestCase
  class TestBar
    include Concerns::OverallBar::Results
  end

  def test_remove_duplicate_discipline_results_single_score
    bar = TestBar.new
    bar.stubs("find_category").returns(stub("category"))
    score = stub(
      "score",
      :points => 1,
      :source_discipline => "Road",
      :source_result => stub("source_result",
        :race => stub("race",
          :category => stub("category")
        )
      )
    )
    # remove_duplicate_discipline_results modifies scores directly becuase it's an ActiveRecord association
    scores = [ score ]
    bar.remove_duplicate_discipline_results(scores)
    assert_equal [ score ], scores, "scores"
  end

  def test_remove_duplicate_discipline_results_multiple
    bar = TestBar.new
    bar.stubs("find_category")
    bar.stubs("logger").returns(stub(:debug? => false))

    score_1 = stub(
      "score 1",
      :destroy => true,
      :points => 20,
      :source_discipline => "Road",
      :source_result => stub("source_result",
        :race => stub("race",
          :category => stub("category")
        )
      )
    )

    score_2 = stub(
      "score 2",
      :destroy => true,
      :points => 10,
      :source_discipline => "Road",
      :source_result => stub("source_result",
        :race => stub("race",
          :category => stub("category")
        )
      )
    )

    score_3 = stub(
      "score 3",
      :destroy => true,
      :points => 5,
      :source_discipline => "Track",
      :source_result => stub("source_result",
        :race => stub("race",
          :category => stub("category")
        )
      )
    )

    scores = [ score_1, score_2, score_3 ]
    bar.remove_duplicate_discipline_results(scores)
    assert_equal [ score_1, score_3 ], scores, "scores"
  end
end
