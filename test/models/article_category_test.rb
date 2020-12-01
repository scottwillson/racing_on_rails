# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class ArticleCategoryTest < ActiveSupport::TestCase
  test "is a tree" do
    root = FactoryBot.create(:article_category)
    child = root.children.create!
    assert_equal root, child.root, "root"
  end
end
