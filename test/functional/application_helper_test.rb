require "test_helper"

# :stopdoc:
class ApplicationHelperTest < ActionView::TestCase
  def test_truncate_from_end
    assert_equal("...s_2009_4_1upload.xls", truncate_from_end("/tmp/racers_2009_4_1upload.xls"), "/tmp/racers_2009_4_1upload.xls")
    assert_equal("", truncate_from_end(""), "blank")
    assert_equal(nil, truncate_from_end(nil), "nil")
    assert_equal("upload.xls", truncate_from_end("upload.xls"), "upload.xls")
  end
end
