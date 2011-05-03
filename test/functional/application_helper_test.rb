require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ApplicationHelperTest < ActionView::TestCase
  def test_truncate_from_end
    assert_equal("...s_2009_4_1upload.xls", truncate_from_end("/tmp/racers_2009_4_1upload.xls"), "/tmp/racers_2009_4_1upload.xls")
    assert_equal("", truncate_from_end(""), "blank")
    assert_equal(nil, truncate_from_end(nil), "nil")
    assert_equal("upload.xls", truncate_from_end("upload.xls"), "upload.xls")
  end

  def test_to_excel
    assert_equal("", to_excel(""), "''")
    assert_equal(nil, to_excel(nil), "nil")
    assert_equal("word", to_excel("word"), "word")
    assert_equal("This is a sentence", to_excel("This is a sentence"), "This is a sentence")
    assert_equal("This has a tab", to_excel("This has\ta tab"), 'This has\ta tab')
    assert_equal("This has   tabs ", to_excel("This has\t\t\ttabs\t"), 'This has\t\t\ttabs\t')
    assert_equal("expected  ", to_excel("expected\r\n"), "expected\r\n")
    assert_equal("  ", to_excel("\n\n"), "\\n\\n")
  end
end
