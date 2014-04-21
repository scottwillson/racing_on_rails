require "will_paginate/array"
require "test_helper"

# :stopdoc:
class CategoriesControllerTest < ActionController::TestCase
  setup :use_ssl

  test "index" do
    @controller.expects(:find_categories).with("").returns([FactoryGirl.build(:category, id: 1)])
    get :index
  end

  test "search" do
    FactoryGirl.create(:category, name: "Senior Men")
    juniors = FactoryGirl.create(:category, name: "Juniors")
    get :index, name: "Jun"
    assert_equal [ juniors ], assigns(:categories), "Should assign categories matching 'Jun'"
  end

  test "index search calls categories" do
    @controller.expects(:find_categories).with("Juniors").returns([FactoryGirl.build(:category, id: 1)])
    get :index, name: "Juniors"
  end
end
