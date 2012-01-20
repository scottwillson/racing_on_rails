require File.expand_path("../../test_helper", __FILE__)


class EditorRequestsTest < ActiveSupport::TestCase
  def test_create
    ActionMailer::Base.deliveries.clear
    editor = FactoryGirl.create(:person_with_login)
    person = FactoryGirl.create(:person_with_login, :email => "hotwheels@yahoo.com")
    editor_request = person.editor_requests.create!(:editor => editor)
    assert_equal "hotwheels@yahoo.com", editor_request.email, "email"
    assert_equal [ editor_request ], person.editor_requests, "FactoryGirl.create(:person).editor_requests"
    assert_equal [ editor_request ], editor.sent_editor_requests, "FactoryGirl.create(:person).sent_editor_requests"
    assert editor_request.expires_at > Time.now, "Should expire in future" 
    assert editor_request.expires_at < 2.weeks.from_now, "Should expire in less than 2 weeks" 
    assert !person.editors.include?(editor), "Should not add promoter as editor of member"
    assert ActionMailer::Base.deliveries.any?, "Should send email to account holder"
  end
  
  def test_validation
    editor = FactoryGirl.create(:person)
    person = Person.create!
    editor_request = person.editor_requests.create(:editor => editor)
    assert editor_request.errors.any?, "should not allow EditorRequest with no email"
  end
  
  def test_grant
    editor = FactoryGirl.create(:person_with_login)
    person = FactoryGirl.create(:person_with_login)
    editor_request = person.editor_requests.create!(:editor => editor)
    ActionMailer::Base.deliveries.clear
    editor_request.grant!
    assert ActionMailer::Base.deliveries.any?, "Should send email to account holder"
    assert person.editors.include?(editor), "Should add editor"
  end
end
