# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class VelodromesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "not logged in index" do
      destroy_person_session
      get :index
      assert_redirected_to new_person_session_url
      assert_nil(@request.session["person"], "No person in session")
    end

    test "index" do
      FactoryBot.create(:velodrome)
      get :index
      assert_response(:success)
      assert_template("admin/velodromes/index")
      assert_not_nil(assigns["velodromes"], "Should assign velodromes")
      assert_not(assigns["velodromes"].empty?, "Should have no velodromes")
    end

    test "new" do
      get(:new)
      assert_response(:success)
      assert_not_nil(assigns["velodrome"], "Should assign velodrome")
    end

    test "create" do
      post(:create, params: { velodrome: { name: "Hellyer", website: "www.hellyer.org" } })
      velodrome = Velodrome.find_by(name: "Hellyer")
      assert_not_nil(velodrome, "Should create new Velodrome")
      assert_equal("www.hellyer.org", velodrome.website, "website")
      assert_redirected_to(new_admin_velodrome_path)
      assert_not_nil(flash[:notice], "Should have flash :notice")
      assert_nil(flash[:warn], "Should have flash :warn")
    end

    test "edit" do
      velodrome = FactoryBot.create(:velodrome)
      get(:edit, params: { id: velodrome.id })
      assert_response(:success)
      assert_equal(velodrome, assigns["velodrome"], "Should assign velodrome")
    end

    test "update" do
      velodrome = FactoryBot.create(:velodrome)
      put(:update, params: { id: velodrome.id, velodrome: { name: "T Town", website: "www" } })
      assert_redirected_to(edit_admin_velodrome_path(velodrome))
      velodrome.reload
      assert_equal("T Town", velodrome.name, "Name should be updated")
      assert_equal("www", velodrome.website, "Websit should be updated")
    end

    test "destroy" do
      velodrome = FactoryBot.create(:velodrome)
      delete :destroy, params: { id: velodrome.id }
      assert_not(Velodrome.exists?(velodrome.id), "Should delete velodrome")
      assert_not_nil(flash[:notice], "Should have flash :notice")
    end

    test "update name" do
      velodrome = FactoryBot.create(:velodrome)
      put :update_attribute,
          params: {
            id: velodrome.to_param,
            value: "Paul Allen Velodrome",
            name: "name"
          },
          xhr: true
      assert_response(:success)
      velodrome.reload
      assert_equal("Paul Allen Velodrome", velodrome.name, "Velodrome name should change after update")
    end

    test "update website" do
      velodrome = FactoryBot.create(:velodrome)
      put :update_attribute,
          params: {
            id: velodrome.to_param,
            value: "www.raceatra.com",
            name: "website"
          },
          xhr: true
      assert_response(:success)
      velodrome.reload
      assert_equal("www.raceatra.com", velodrome.website, "Velodrome website should change after update")
    end
  end
end
