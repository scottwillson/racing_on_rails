require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ApplicationHelperTest < ActionView::TestCase
  test "truncate from end" do
    assert_equal("...s_2009_4_1upload.xls", truncate_from_end("/tmp/racers_2009_4_1upload.xls"), "/tmp/racers_2009_4_1upload.xls")
    assert_equal("", truncate_from_end(""), "blank")
    assert_equal(nil, truncate_from_end(nil), "nil")
    assert_equal("upload.xls", truncate_from_end("upload.xls"), "upload.xls")
  end

  test "to excel" do
    assert_equal("", to_excel(""), "''")
    assert_equal("", to_excel(nil), "nil")
    assert_equal("word", to_excel("word"), "word")
    assert_equal("This is a sentence", to_excel("This is a sentence"), "This is a sentence")
    assert_equal("This has a tab", to_excel("This has\ta tab"), 'This has\ta tab')
    assert_equal("This has   tabs ", to_excel("This has\t\t\ttabs\t"), 'This has\t\t\ttabs\t')
    assert_equal("expected  ", to_excel("expected\r\n"), "expected\r\n")
    assert_equal("  ", to_excel("\n\n"), "\\n\\n")
    assert_equal("\"foo\"", to_excel("\"foo\""), "Should escape double quotes")
    assert_equal("\"a,b\"", to_excel("a,b"), "Should escape double quotes")
    assert_equal("9/8/2010", to_excel(Time.zone.local(2010, 9, 8).to_date), "date 2010-09-08")
  end
end
