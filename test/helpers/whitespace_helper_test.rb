require "test_helper"

# :stopdoc:
class WhitespaceTest < ActionView::TestCase
  include WhitespaceHelper

  test "show_whitespace" do
    assert_equal nil, show_whitespace(nil), "nil"
    assert_equal "", show_whitespace(""), "blank"
    assert_equal "Senior", show_whitespace("Senior"), "Senior"
    assert_equal "·Senior··", show_whitespace(" Senior  "), "Senior with whitespace"
    assert_equal "Senior Men", show_whitespace("Senior Men"), "Senior Men"
  end
end
