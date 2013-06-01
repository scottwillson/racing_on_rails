require 'test_helper'

class PhotosControllerTest < ActionController::TestCase
  test "index" do
    FactoryGirl.create(:photo)
    login_as :administrator
    get :index
    assert_response :success
  end
  
  test "empty index" do
    login_as :administrator
    get :index
    assert_response :success
  end
  
  test "edit" do
    photo = FactoryGirl.create(:photo)
    login_as :administrator
    get :edit, :id => photo.id
    assert_response :success
    assert_equal photo, assigns(:photo), "@photo"
  end
  
  test "create" do
    login_as :administrator
    
    Photo.any_instance.stubs :height => 300, :width => 400
    
    post :create, :photo => {
      :caption => "Caption",
      :image => fixture_file_upload("../files/photo.jpg")
    }

    assert_redirected_to edit_photo_path(assigns(:photo))
  end
  
  test "edit should require administrator" do
    photo = FactoryGirl.create(:photo)
    get :edit, :id => photo.id
    assert_redirected_to new_person_session_path
  end
  
  test "new should require administrator" do
    get :new
    assert_redirected_to new_person_session_path
  end
  
  test "create should require administrator" do
    post :create, :photo => {
      :caption => "Caption",
      :title => "Title",
      :image => fixture_file_upload("../files/photo.jpg")
    }
    assert_redirected_to new_person_session_path
  end
  
  test "update should require administrator" do
    photo = FactoryGirl.create(:photo)
    put :update, :id => photo.id, :photo => { :caption => "New Caption" }
    assert_redirected_to new_person_session_path
  end
end
