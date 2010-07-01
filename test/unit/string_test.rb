require File.expand_path("../../test_helper", __FILE__)

class StringTest < ActiveSupport::TestCase
  def test_to_excel
    assert_equal("", "".to_excel, "''")
    assert_equal(nil, nil.to_excel, "nil")
    assert_equal("word", "word".to_excel, "word")
    assert_equal("This is a sentence", "This is a sentence".to_excel, "This is a sentence")
    assert_equal("This has a tab", "This has\ta tab".to_excel, 'This has\ta tab')
    assert_equal("This has   tabs ", "This has\t\t\ttabs\t".to_excel, 'This has\t\t\ttabs\t')
    assert_equal("expected  ", "expected\r\n".to_excel, "expected\r\n")
  end
end