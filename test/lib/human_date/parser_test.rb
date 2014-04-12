require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module HumanDate
  class ParserTest < ActiveSupport::TestCase
    test "parse human date" do
      # Unspecified time defaults to noon
      assert_equal Time.zone.local(2013, 7, 29, 12), HumanDate::Parser.new.parse("Monday, July 29, 2013")
    end

    test "parse nil" do
      assert_equal nil, HumanDate::Parser.new.parse(nil)
    end

    test "parse ISO date time" do
      assert_equal Time.utc(2013, 11, 28, 8, 0, 0), HumanDate::Parser.new.parse("2013-11-28T08:00:00.000Z").utc
      assert_equal Time.utc(2010, 12, 27, 19, 28, 18, 157000), HumanDate::Parser.new.parse("2010-12-27T19:28:18.157Z.json").utc
    end

    test "parse bogus date should return nil" do
      assert_equal nil, HumanDate::Parser.new.parse("XYZ")
    end
  end
end
