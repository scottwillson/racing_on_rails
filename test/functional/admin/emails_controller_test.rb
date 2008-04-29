require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/emails_controller'

class Admin::EmailsController; def rescue_action(e) raise e end; end

class Admin::EmailsControllerTest < ActiveSupport::TestCase
  def setup
    @controller = Admin::EmailsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:candi)
  end

  def test_new
    get(:new)
    assert_response(:success)
    assert_not_nil(assigns['email'], 'Should assign email')
  end
end
