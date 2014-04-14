require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class FirstAidProvidersControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "index" do
      FactoryGirl.create(:event, date: 3.days.from_now)
      get(:index)
      assert_response(:success)
      assert_template("admin/first_aid_providers/index")
      assert_not_nil(assigns["events"], "Should assign events")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_equal(false, assigns["past_events"], "past_events")
      assert_equal("date", assigns["sort_by"], "@sort_by default")
      assert_select ".editable", { minimum: 1 }, "Should be editable for admins"
    end

    test "index as txt" do
      FactoryGirl.create :event, date: 3.days.from_now
      get :index, format: "text"
      assert_response :success
    end

    test "first aid update options" do
      get(:index, past_events: "true")
      assert_response(:success)
      assert_template("admin/first_aid_providers/index")
      assert_not_nil(assigns["events"], "Should assign events")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_equal(true, assigns["past_events"], "past_events")
    end

    test "index sorting" do
      get(:index, sort_by: "promoter_name", sort_direction: "desc")
      assert_response(:success)
      assert_template("admin/first_aid_providers/index")
      assert_not_nil(assigns["events"], "Should assign events")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_equal(false, assigns["past_events"], "past_events")
      assert_equal("promoter_name", assigns["sort_by"], "@sort_by from param")
    end

    test "non official" do
      login_as FactoryGirl.create(:person)
      get :index
      assert_redirected_to new_person_session_url(secure_redirect_options)
      assert_select ".in_place_editable", 0, "Should be read-only for officials"
    end

    test "official" do
      person = FactoryGirl.create(:person_with_login, official: true)
      login_as person
      get :index
      assert_response :success
    end

    test "email" do
      FactoryGirl.create(:event, date: 3.days.from_now)
      get :index, format: "text"
      assert_response :success
    end
  end
end
