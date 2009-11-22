require 'test_helper'

class Admin::Pages::VersionsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  test "Edit page version" do
    version = pages(:plain).versions.latest
    get(:edit, :id => version.to_param)
    assert_response(:success)
  end
  
  test "Show old version" do
    page = Page.create!(:body => "<h1>Welcome</h1>")
    page.body = "<h1>TTYL!</h1>"
    page.save!
    get(:show, :id => page.versions.earliest.to_param)
    assert_select("h1", :text => "Welcome")
  end
  
  test "Delete old version" do
    page = Page.create!(:body => "<h1>Welcome</h1>")
    page.body = "<h1>TTYL!</h1>"
    page.save!
    
    assert_equal(2, page.versions.size, "versions")
    delete(:destroy, :id => page.versions.earliest.to_param)

    assert_equal(1, page.versions.size, "versions")
  end
  
  test "Revert to version" do
    page = Page.create!(:body => "<h1>Welcome</h1>")
    page.body = "<h1>TTYL!</h1>"
    page.save!
    
    get(:revert, :id => page.versions.earliest.to_param)
    
    page.reload
    assert_equal(1, page.version, "version")
    assert_equal("<h1>Welcome</h1>", page.body, "body")
  end
end
