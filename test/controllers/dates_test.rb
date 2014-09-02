require "test_helper"

# :stopdoc:
class DatesTest < ActionController::TestCase
  tests HomeController

  test "assign_today" do
    travel_to Time.zone.local(2014, 2, 3) do
      get :index
      assert_equal Time.zone.local(2014, 2, 3).to_date, assigns("today")
    end
  end

  test "assign_year" do
    travel_to Time.zone.local(2014, 2, 3) do
      get :index
      assert_equal 2014, assigns("year")
    end
  end
end
