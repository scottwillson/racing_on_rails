# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class RacesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "edit" do
      kings_valley_3 = FactoryBot.create(:race)
      get :edit, params: { id: kings_valley_3.to_param }
      assert_response(:success)
      assert_template("admin/races/edit")
      assert_not_nil(assigns["race"], "Should assign race")
      assert_equal(kings_valley_3, assigns["race"], "Should assign kings_valley_3 race")
    end

    test "edit own race" do
      race = FactoryBot.create(:race)
      login_as race.promoter
      get :edit, params: { id: race.to_param }
      assert_response :success
      assert_template "admin/races/edit"
      assert_not_nil assigns["race"], "Should assign race"
    end

    test "cannot edit someone elses race" do
      race = FactoryBot.create(:race)
      login_as FactoryBot.create(:person)
      get :edit, params: { id: race.to_param }
      assert_redirected_to unauthorized_path
    end

    test "update" do
      race = FactoryBot.create(:race)
      put :update, params: { id: race.to_param, race: { category_name: "Open", event_id: race.event.to_param } }
      assert_redirected_to edit_admin_race_path(race)
    end

    test "destroy" do
      kings_valley_women_2003 = FactoryBot.create(:race)
      delete :destroy, params: { id: kings_valley_women_2003.id, commit: "Delete" }, xhr: true
      assert_response(:success)
      assert_raise(ActiveRecord::RecordNotFound, "kings_valley_women_2003 should have been destroyed") { Race.find(kings_valley_women_2003.id) }
    end

    test "new" do
      event = FactoryBot.create(:event)
      get :new, params: { event_id: event.to_param }
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_template :edit
    end

    test "new as promoter" do
      event = FactoryBot.create(:event)
      login_as event.promoter
      get :new, params: { event_id: event.to_param }
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_template :edit
    end

    test "create" do
      event = FactoryBot.create(:event)
      assert event.races.none? { |race| race.category_name == "Senior Women" }
      post :create, params: { race: { category_name: "Senior Women", event_id: event.to_param } }
      assert_not_nil assigns(:race), "@race"
      assert_redirected_to edit_admin_race_path assigns(:race)
      assert event.races.reload.any? { |race| race.category_name == "Senior Women" }
    end

    test "invalid create" do
      event = FactoryBot.create(:event)
      assert event.races.none? { |race| race.category_name == "Senior Women" }
      post :create, params: { race: { category_name: "", event_id: event.to_param } }
      assert_not_nil assigns(:race), "@race"
      assert_response :success
      assert event.races.none? { |race| race.category_name == "Senior Women" }
    end

    test "create xhr" do
      event = FactoryBot.create(:event)
      post :create, params: { event_id: event.to_param }, xhr: true
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "New Category", assigns(:race).name, "@race name"
      assert_not assigns(:race).new_record?, "@race should be created"
      assert_template "admin/races/create", "template"
    end

    test "create xhr promoter" do
      event = FactoryBot.create(:event)
      login_as event.promoter
      post :create, params: { event_id: event.to_param }, xhr: true
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "New Category", assigns(:race).name, "@race name"
      assert_not assigns(:race).new_record?, "@race should be created"
      assert_template "admin/races/create", "template"
    end

    test "admin set race category name" do
      race = FactoryBot.create(:race)
      put :update_attribute, params: { id: race.to_param, value: "Fixed Gear", name: "category_name" }, xhr: true
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
    end

    test "promoter set race category name" do
      race = FactoryBot.create(:race)
      login_as race.promoter
      put :update_attribute, params: { id: race.to_param, value: "Fixed Gear", name: "category_name" }, xhr: true
      assert_response :success
      assert_not_nil assigns(:race), "@race"
      assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
    end

    test "propagate" do
      event = FactoryBot.create(:event)
      login_as event.promoter
      post :propagate, params: { event_id: event.to_param }, xhr: true
      assert_response :success
      assert_template "admin/races/propagate", "template"
    end
  end
end
