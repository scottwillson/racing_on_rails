require File.expand_path("../../test_case", __FILE__)
require File.expand_path("../../../../lib/ages", __FILE__)

# :stopdoc:
class AgesTest < Ruby::TestCase
  class Stub
    include Ages
    attr_accessor :ages_begin, :ages_end
  end

  test "ages" do
    stub = Stub.new
    stub.ages = 12..15
    assert_equal 12, stub.ages_begin, "ages_begin"
    assert_equal 15, stub.ages_end, "ages_end"
    assert_equal 12..15, stub.ages, "Default age range"
  end

  test "set_ages_as_string" do
    stub = Stub.new
    stub.ages = "12-15"
    assert_equal 12, stub.ages_begin, "ages_begin"
    assert_equal 15, stub.ages_end, "ages_end"
    assert_equal 12..15, stub.ages, "Default age range"
  end
end
