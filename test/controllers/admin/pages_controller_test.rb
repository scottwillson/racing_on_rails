# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class PagesControllerTest < ActionController::TestCase
    setup :create_administrator_session
    setup :use_ssl

    test "only admins can edit pages" do
      destroy_person_session
      get :index
      assert_redirected_to new_person_session_url
    end

    test "view pages as tree" do
      get :index
      assert_response(:success)
    end

    test "update title inplace" do
      page = FactoryBot.create(:page)

      patch :update_attribute,
            params: {
              id: page.to_param,
              value: "OBRA Banquet",
              name: "title"
            },
            xhr: true
      assert_response(:success)
      assert_template(nil)
      assert_equal(page, assigns("page"), "@page")
      page.reload
      assert_equal("OBRA Banquet", page.title, "Page title")
    end

    test "edit page" do
      page = FactoryBot.create(:page)
      get :edit, params: { id: page.id }
    end

    test "update page" do
      page = FactoryBot.create(:page)
      put :update,
          params: {
            id: page.to_param,
            page: {
              title: "My Awesome Bike Racing Page",
              body: "<blink>Race</blink>",
              parent_id: nil
            }
          }
      assert_redirected_to(edit_admin_page_path(page))
      page = Page.find(page.id)
      assert_equal("My Awesome Bike Racing Page", page.title, "title")
      assert_equal("<blink>Race</blink>", page.body, "body")
    end

    test "update page parent" do
      parent_page = Page.create!(title: "Root")
      page = FactoryBot.create(:page)
      put :update,
          params: {
            id: page.to_param,
            page: {
              title: "My Awesome Bike Racing Page",
              body: "<blink>Race</blink>",
              parent_id: parent_page.to_param
            }
          }
      page.reload
      assert_equal("My Awesome Bike Racing Page", page.title, "title")
      assert_equal("<blink>Race</blink>", page.body, "body")
      assert_equal(parent_page, page.parent, "Page parent")
      assert_redirected_to(edit_admin_page_path(page))
    end

    test "new page" do
      get(:new)
    end

    test "new page parent" do
      assert_equal 0, Page.count
      parent_page = FactoryBot.create(:page)
      get :new, params: { page: { parent_id: parent_page.to_param } }
      page = assigns(:page)
      assert_not_nil(page, "@page")
      assert_equal(parent_page, page.parent, "New page parent")
    end

    test "create page" do
      put(:create,
          params: {
            page: {
              title: "My Awesome Bike Racing Page",
              body: "<blink>Race</blink>"
            }
          })
      page = Page.find_by(title: "My Awesome Bike Racing Page")
      assert_redirected_to(edit_admin_page_path(page))
      page.reload
      assert_equal("My Awesome Bike Racing Page", page.title, "title")
      assert_equal("<blink>Race</blink>", page.body, "body")
    end

    test "create child page" do
      parent_page = FactoryBot.create(:page)
      post :create,
           params: {
             page: {
               title: "My Awesome Bike Racing Page",
               body: "<blink>Race</blink>",
               parent_id: parent_page.to_param
             }
           }
      page = Page.find_by(title: "My Awesome Bike Racing Page")
      assert_redirected_to(edit_admin_page_path(page))
      page.reload
      assert_equal("My Awesome Bike Racing Page", page.title, "title")
      assert_equal("<blink>Race</blink>", page.body, "body")
      assert_equal(parent_page, page.parent, "Page parent")
    end

    test "delete page" do
      page = FactoryBot.create(:page)
      delete :destroy, params: { id: page.to_param }
      assert_redirected_to(admin_pages_path)
      assert_not Page.exists?(page.id), "Page should be deleted"
    end

    test "delete parent page" do
      page = FactoryBot.create(:page)
      page.children.create!
      page.reload
      delete :destroy, params: { id: page.to_param }
      assert_redirected_to(admin_pages_path)
      assert_not(Page.exists?(page.id), "Page should be deleted")
    end

    test "delete child page" do
      page = FactoryBot.create(:page).children.create!
      delete :destroy, params: { id: page.to_param }
      assert_redirected_to(admin_pages_path)
      assert_not(Page.exists?(page.id), "Page should be deleted")
    end
  end
end
