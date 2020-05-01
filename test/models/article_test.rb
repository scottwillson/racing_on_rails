# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ArticleTest < ActiveSupport::TestCase
  test "move in list" do
    article_category = FactoryBot.create(:article_category)
    article = FactoryBot.create(:article, article_category: article_category)
    article_2 = FactoryBot.create(:article, article_category: article_category)
    assert_equal [article_2, article], Article.all.sort_by(&:position), "Should be sorted"
  end
end
