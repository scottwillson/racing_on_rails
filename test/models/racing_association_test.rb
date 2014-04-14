require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
# Check we can call these methods with errors.
# Actual values are going to differ between sites.
class RacingAssociationTest < ActiveSupport::TestCase
 test "show events velodrome" do
   RacingAssociation.current.show_events_velodrome?
 end

  test "competitions" do
    default_competitions = RacingAssociation.current.competitions
    RacingAssociation.current.competitions.clear
    RacingAssociation.current.competitions << :ironman
    RacingAssociation.current.competitions << :ironman
    begin
      assert(RacingAssociation.current.competitions.include?(:ironman), "Racing association competitions should include Ironman")
      assert(!RacingAssociation.current.competitions.include?(:bar), "Racing association competitions should not include Bar")
      assert_equal(1, RacingAssociation.current.competitions.size, "Should only include one instance of Ironman competition")
    ensure
      RacingAssociation.current.competitions = default_competitions
    end
  end

  test "today" do
    assert_equal_dates Time.zone.today, RacingAssociation.current.today, "Default RacingAssociation.current.today"

    Timecop.freeze(Time.zone.local(2020, 4, 5, 23, 50, 55)) do
      assert_equal_dates Date.new(2020, 4, 5), RacingAssociation.current.today, "Override Time.zone.now to change RacingAssociation.current.today"
    end

    assert_equal_dates Time.zone.today, RacingAssociation.current.today, "Default RacingAssociation.current.today should be Time.zone.today after Time.zone.now is set to nil"
  end

  test "effective year" do
    Timecop.freeze(Time.zone.local(2020, 1, 1)) do
      assert_equal 2020, RacingAssociation.current.effective_year, "effective year for January 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 11, 30)) do
      assert_equal 2020, RacingAssociation.current.effective_year, "effective year for November 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 12, 15)) do
      assert_equal 2020, RacingAssociation.current.effective_year, "effective year for December 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 12, 16)) do
      assert_equal 2021, RacingAssociation.current.effective_year, "effective year for December 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 12, 31)) do
      assert_equal 2021, RacingAssociation.current.effective_year, "effective year for December 2020"
    end
  end

  test "effective year range" do
    Timecop.freeze(Time.zone.local(2020, 1, 1)) do
      assert_equal(
        Time.zone.local(2020, 1, 1).beginning_of_year.to_date..Time.zone.local(2020, 1, 1).end_of_year.to_date,
        RacingAssociation.current.effective_year_range,
        "effective_year_range for January 2020"
      )
    end
  end

  test "next year" do
    Timecop.freeze(Time.zone.local(2020, 1, 1)) do
      assert_equal 2021, RacingAssociation.current.next_year, "next_year for January 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 11, 30)) do
      assert_equal 2021, RacingAssociation.current.next_year, "next_year for November 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 12, 1)) do
      assert_equal 2021, RacingAssociation.current.next_year, "next_year for December 2020"
    end

    Timecop.freeze(Time.zone.local(2020, 12, 31)) do
      assert_equal 2021, RacingAssociation.current.next_year, "next_year for December 2020"
    end
  end

  test "next year start at" do
    racing_association = RacingAssociation.current
    racing_association.next_year_start_at = Time.zone.local(2014, 12, 15)
    racing_association.save!

    Timecop.freeze(Time.zone.local(2014, 1, 1)) do
      assert_equal 2014, RacingAssociation.current.effective_year, "effective year for January 1, 2014"
      assert_equal 2015, RacingAssociation.current.next_year, "next_year for January 2014"
    end

    Timecop.freeze(Time.zone.local(2014, 12, 14)) do
      assert_equal 2014, RacingAssociation.current.effective_year, "effective year for December 14, 2014"
      assert_equal 2015, RacingAssociation.current.next_year, "next_year for December 14 2014"
    end

    Timecop.freeze(Time.zone.local(2014, 12, 15)) do
      assert_equal 2015, RacingAssociation.current.effective_year, "effective year for December 15, 2014"
      assert_equal 2015, RacingAssociation.current.next_year, "next_year for December 15 2014"
    end

    Timecop.freeze(Time.zone.local(2014, 12, 16)) do
      assert_equal 2015, RacingAssociation.current.effective_year, "effective year for December 16, 2014"
      assert_equal 2015, RacingAssociation.current.next_year, "next_year for December 16 2014"
    end

    Timecop.freeze(Time.zone.local(2014, 12, 31)) do
      assert_equal 2015, RacingAssociation.current.effective_year, "effective year for December 31, 2014"
      assert_equal 2015, RacingAssociation.current.next_year, "next_year for December 31 2014"
    end

    Timecop.freeze(Time.zone.local(2015, 1, 1)) do
      assert_equal 2015, RacingAssociation.current.effective_year, "effective year for January 1, 2015"
      assert_equal 2016, RacingAssociation.current.next_year, "next_year for January 2014"
    end

    Timecop.freeze(Time.zone.local(2015, 12, 15)) do
      assert_equal 2015, RacingAssociation.current.effective_year, "effective year for December 15, 2014"
      assert_equal 2016, RacingAssociation.current.next_year, "next_year for December 15 2014"
    end

    Timecop.freeze(Time.zone.local(2015, 12, 16)) do
      assert_equal 2016, RacingAssociation.current.effective_year, "effective year for December 16, 2014"
      assert_equal 2016, RacingAssociation.current.next_year, "next_year for December 16 2014"
    end

    Timecop.freeze(Time.zone.local(2015, 12, 17)) do
      assert_equal 2016, RacingAssociation.current.effective_year, "effective year for December 17, 2014"
      assert_equal 2016, RacingAssociation.current.next_year, "next_year for December 17 2014"
    end

    Timecop.freeze(Time.zone.local(2015, 12, 31)) do
      assert_equal 2016, RacingAssociation.current.effective_year, "effective year for December 31, 2014"
      assert_equal 2016, RacingAssociation.current.next_year, "next_year for December 31 2014"
    end
  end

  test "number issuer" do
    assert_equal nil, RacingAssociation.current.number_issuer

    FactoryGirl.create(:number_issuer, name: "AVC")
    number_issuer = FactoryGirl.create(:number_issuer, name: RacingAssociation.current.short_name)

    assert_equal number_issuer, RacingAssociation.current.number_issuer
  end
end
