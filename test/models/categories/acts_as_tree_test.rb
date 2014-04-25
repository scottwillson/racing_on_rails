require "test_helper"

module Categories
  # :stopdoc:
  class ActsAsTreeTest < ActiveSupport::TestCase
    test "#descendants should not modify association" do
      root = FactoryGirl.create(:category)
      node = FactoryGirl.create(:category, parent: root)
      leaf = FactoryGirl.create(:category, parent: node)

      root.reload.descendants
      node.reload.descendants
      leaf.reload.descendants

      assert_equal nil, root.reload.parent, "root parent"
      assert_equal root, node.reload.parent, "node parent"
      assert_equal node, leaf.reload.parent, "leaf parent"
    end
  end
end
