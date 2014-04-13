require File.expand_path("../../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class Pages::VersionsControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "Edit page version" do
      page = FactoryGirl.create(:page)
      page.update_attributes :title => "New Title"
      version = page.versions.last
      get(:edit, :id => version.to_param)
      assert_response(:success)
    end

    test "Show old version" do
      page = Page.create!(:body => "<h1>Welcome</h1>")
      page.body = "<h1>foo</h1>"
      page.save!
      page.body = "<h1>TTYL!</h1>"
      page.save!
      get(:show, :id => page.versions.first.to_param)
      assert_select("h1", :text => "TTYL!")
    end

    test "Delete old version" do
      page = Page.create!(:body => "<h1>Welcome</h1>")
      page.body = "<h1>TTYL!</h1>"
      page.save!

      assert_equal(2, page.versions.size, "versions")
      delete(:destroy, :id => page.versions.first.to_param)

      assert_equal(1, page.versions.size, "versions")
    end

    test "Revert to version" do
      page = Page.create!(:body => "<h1>Welcome</h1>")
      page.title = "Title"
      page.save!
      page.body = "<h1>TTYL!</h1>"
      page.save!

      get(:revert, :id => page.versions.first.to_param)

      page.reload
      assert_equal(4, page.version, "version")
      assert_equal("<h1>Welcome</h1>", page.body, "body")
    end
  end
end
