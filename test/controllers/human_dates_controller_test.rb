# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class HumanDatesControllerTest < ActionController::TestCase
  test "parse human date" do
    get :show, params: { date: "Monday, July 29, 2013" }
    assert_equal "\"Monday, July 29, 2013\"", @response.body
  end

  test "parse ISO date time" do
    get :show, params: { date: "2010-12-27T19:28:18.157Z" }
    assert_equal "\"Monday, December 27, 2010\"", @response.body
  end

  test "parse bogus date" do
    get :show, params: { date: "XYZ" }
    assert_equal "\"XYZ\"", @response.body
  end

  test "delegate to date parser" do
    @controller.stubs(:parser).returns(mock("parser", parse: Time.zone.local(2013, 7, 29)))
    get :show, params: { date: "7/29/2013" }
  end
end
