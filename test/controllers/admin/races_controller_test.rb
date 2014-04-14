require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class RacesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "edit" do
      kings_valley_3 = FactoryGirl.create(:race)
      get(:edit, id: kings_valley_3.to_param)
      assert_response(:success)
      assert_template("admin/races/edit")
      assert_not_nil(assigns["race"], "Should assign race")
      assert_equal(kings_valley_3, assigns["race"], "Should assign kings_valley_3 race")
    end

    test "edit own race" do
      race = FactoryGirl.create(:race)
      login_as race.promoter
      get :edit, id: race.to_param
      assert_response :success
      assert_template "admin/races/edit"
      assert_not_nil assigns["race"], "Should assign race"
    end

    test "cannot edit someone elses race" do
      race = FactoryGirl.create(:race)
      login_as FactoryGirl.create(:person)
      get :edit, id: race.to_param
      assert_redirected_to unauthorized_path
    end

    test "update" do
      race = FactoryGirl.create(:race)
      put :update, id: race.to_param, race: { category_name: "Open", event_id: race.event.to_param }
      assert_redirected_to edit_admin_race_path(race)
    end

    test "destroy" do
      kings_valley_women_2003 = FactoryGirl.create(:race)
      xhr :delete, :destroy, id: kings_valley_women_2003.id, commit: 'Delete'
      assert_response(:success)
      assert_raise(ActiveRecord::RecordNotFound, 'kings_valley_women_2003 should have been destroyed') { Race.find(kings_valley_women_2003.id) }
    end

    test "new" do
      event = FactoryGirl.create(:event)
      get :new, event_id: event.to_param
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_template :edit
    end

    test "new as promoter" do
      event = FactoryGirl.create(:event)
      login_as event.promoter
      get :new, event_id: event.to_param
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_template :edit
    end

    test "create" do
      event = FactoryGirl.create(:event)
      assert event.races.none? { |race| race.category_name == "Senior Women" }
      post :create, race: { category_name: "Senior Women", event_id: event.to_param }
      assert_not_nil assigns(:race), "@race"
      assert_redirected_to edit_admin_race_path assigns(:race)
      assert event.races(true).any? { |race| race.category_name == "Senior Women" }
    end

    test "invalid create" do
      event = FactoryGirl.create(:event)
      assert event.races.none? { |race| race.category_name == "Senior Women" }
      post :create, race: { category_name: "", event_id: event.to_param }
      assert_not_nil assigns(:race), "@race"
      assert_response :success
      assert event.races.none? { |race| race.category_name == "Senior Women" }
    end

    test "create xhr" do
      event = FactoryGirl.create(:event)
      xhr :post, :create, event_id: event.to_param
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "New Category", assigns(:race).name, "@race name"
      assert !assigns(:race).new_record?, "@race should be created"
      assert_template "admin/races/create", "template"
    end

    test "create xhr promoter" do
      event = FactoryGirl.create(:event)
      login_as event.promoter
      xhr :post, :create, event_id: event.to_param
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "New Category", assigns(:race).name, "@race name"
      assert !assigns(:race).new_record?, "@race should be created"
      assert_template "admin/races/create", "template"
    end

    test "admin set race category name" do
      race = FactoryGirl.create(:race)
      xhr :put, :update_attribute, id: race.to_param, value: "Fixed Gear", name: "category_name"
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
    end

    test "promoter set race category name" do
      race = FactoryGirl.create(:race)
      login_as race.promoter
      xhr :put, :update_attribute, id: race.to_param, value: "Fixed Gear", name: "category_name"
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
    end

    test "propagate" do
      event = FactoryGirl.create(:event)
      login_as event.promoter
      xhr :post, :propagate, event_id: event.to_param
      assert_response :success
      assert_template "admin/races/propagate", "template"
    end
  end
end
