require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  class CategoriesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "index" do
      get :index
      assert_not_nil assigns["category"], "Should assign category"
      assert_not_nil assigns["unknowns"], "Should assign unknowns"
    end

    test "edit" do
      category = FactoryGirl.create(:category)
      get :edit, id: category
    end

    test "update should save name as-is" do
      category = FactoryGirl.create(:category)
      patch :update, id: category, category: { raw_name: "JUNIORS" }
      assert_equal "JUNIORS", category.reload.name
      assert_redirected_to edit_admin_category_path(category)
    end

    test "invalid update" do
      category = FactoryGirl.create(:category)
      patch :update, id: category, category: { raw_name: "" }
      assert_response :success
    end
  end
end
