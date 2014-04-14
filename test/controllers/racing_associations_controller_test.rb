require File.expand_path("../../test_helper", __FILE__)

class RacingAssociationsControllerTest < ActionController::TestCase
  test "edit" do
    association = RacingAssociation.current
    create_administrator_session
    use_ssl
    get :edit, id: association.to_param
    assert_response :success
  end

  test "update" do
    racing_association = RacingAssociation.current
    create_administrator_session
    use_ssl
    put :update, id: racing_association, racing_association: { name: "NCNCA" }
    assert_redirected_to edit_racing_association_path(racing_association)
    assert_equal "NCNCA", racing_association.reload.name, "name should be updated"
  end
end
