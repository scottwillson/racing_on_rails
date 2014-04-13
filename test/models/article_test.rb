require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ArticleTest < ActiveSupport::TestCase
  test "move in list" do
    article_category = FactoryGirl.create(:article_category)
    article = FactoryGirl.create(:article, :article_category => article_category)
    article_2 = FactoryGirl.create(:article, :article_category => article_category)

    article.move_to_bottom
    assert_equal [ article_2, article ], Article.all.sort, "Should be sorted"

    article_2.move_to_bottom
    assert_equal [ article, article_2 ], Article.all.sort, "Should be sorted"
  end
end
