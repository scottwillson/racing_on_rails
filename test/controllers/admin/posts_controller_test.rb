require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  class PostsControllerTest < ActionController::TestCase
    setup :use_ssl

    test "index" do
      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      get :index, mailing_list_id: mailing_list.to_param
      assert_response :success
      assert_template layout: "admin/application"
    end

    test "non admin index" do
      login_as FactoryGirl.create(:person)
      mailing_list = FactoryGirl.create(:mailing_list)
      get :index, mailing_list_id: mailing_list.to_param
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end

    test "index anonymous" do
      mailing_list = FactoryGirl.create(:mailing_list)
      get :index, mailing_list_id: mailing_list.to_param
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end

    test "new" do
      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      get :new, mailing_list_id: mailing_list.to_param
      assert_response :success
    end

    test "create" do
      Post.expects(:save).returns(true)
      Post.any_instance.expects(:save!).never
      @controller.expects(:edit_admin_mailing_list_post_path).returns("/edit")

      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      post :create, mailing_list_id: mailing_list.to_param, post: {
        from_name: "Mike Murray",
        from_email: "mmurray@obra.org",
        subject: "No More Masters Races",
        body: "That is all",
        "date(1i)"=>"2009",
        "date(2i)"=>"11",
        "date(3i)"=>"22"
      }
      assert_not_nil assigns(:post), @post
      assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
      assert_redirected_to "/edit"
    end

    test "receive" do
      Post.expects(:save).returns(true)
      Post.any_instance.expects(:save!).never

      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list, name: "obra")
      post :receive, mailing_list_id: mailing_list.to_param, raw: fixture_file_upload("email/for_sale.eml")
      assert_not_nil assigns(:post), @post
      assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
      assert_redirected_to admin_mailing_list_posts_path(mailing_list)
    end

    test "edit" do
      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      post = FactoryGirl.create(:post)
      get :edit, mailing_list_id: mailing_list.to_param, id: post.to_param
      assert_response :success
    end

    test "update" do
      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      post = FactoryGirl.create(:post)

      Post.expects(:save).returns(true)
      Post.any_instance.expects(:save!).never

      put :update, mailing_list_id: mailing_list.to_param, id: post.to_param, post: {
        from_name: "Mike Murray",
        from_email: "mmurray@obra.org",
        subject: "No More Masters Races",
        body: "That is all",
        "date(1i)"=>"2009",
        "date(2i)"=>"11",
        "date(3i)"=>"22"
      }
      assert_not_nil assigns(:post), @post
      assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
      assert_equal "No More Masters Races", assigns(:post).subject, "subject"
      assert_redirected_to edit_admin_mailing_list_post_path(mailing_list, assigns(:post))
    end

    test "destroy" do
      login_as FactoryGirl.create(:administrator)
      mailing_list = FactoryGirl.create(:mailing_list)
      post = FactoryGirl.create(:post)
      delete :destroy, mailing_list_id: mailing_list.to_param, id: post.to_param
      assert_redirected_to admin_mailing_list_posts_path(mailing_list)
      assert !Post.exists?(mailing_list.id), "Should delete Post"
    end
  end
end
