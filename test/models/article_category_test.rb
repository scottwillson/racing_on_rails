require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ArticleCategoryTest < ActiveSupport::TestCase
  test "is a tree" do
    root = FactoryGirl.create(:article_category)
    child = root.children.create!
    assert_equal root, child.root, "root"
  end
end
