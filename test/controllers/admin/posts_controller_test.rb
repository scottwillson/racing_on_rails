# frozen_string_literal: true

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  class PostsControllerTest < ActionController::TestCase
    setup :use_ssl

    test "index" do
      login_as FactoryBot.create(:administrator)
      post = FactoryBot.create(:post)
      get :index, params: { mailing_list_id: post.mailing_list.to_param }
      assert_response :success
      assert_template layout: "admin/application"
    end

    test "non admin index" do
      login_as FactoryBot.create(:person)
      mailing_list = FactoryBot.create(:mailing_list)
      get :index, params: { mailing_list_id: mailing_list.to_param }
      assert_redirected_to new_person_session_url
    end

    test "index anonymous" do
      mailing_list = FactoryBot.create(:mailing_list)
      get :index, params: { mailing_list_id: mailing_list.to_param }
      assert_redirected_to new_person_session_url
    end

    test "new" do
      login_as FactoryBot.create(:administrator)
      mailing_list = FactoryBot.create(:mailing_list)
      get :new, params: { mailing_list_id: mailing_list.to_param }
      assert_response :success
    end

    test "create" do
      Post.expects(:save).returns(true)
      Post.any_instance.expects(:save!).never
      @controller.expects(:edit_admin_mailing_list_post_path).returns("/edit")

      login_as FactoryBot.create(:administrator)
      mailing_list = FactoryBot.create(:mailing_list)
      post :create, params: { mailing_list_id: mailing_list.to_param, post: {
        from_name: "Mike Murray",
        from_email: "mmurray@obra.org",
        subject: "No More Masters Races",
        body: "That is all",
        "date(1i)" => "2009",
        "date(2i)" => "11",
        "date(3i)" => "22"
      } }
      assert_not_nil assigns(:post), @post
      assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
      assert_redirected_to "/edit"
    end

    test "edit" do
      login_as FactoryBot.create(:administrator)
      mailing_list = FactoryBot.create(:mailing_list)
      post = FactoryBot.create(:post)
      get :edit, params: { mailing_list_id: mailing_list.to_param, id: post.to_param }
      assert_response :success
    end

    test "update" do
      login_as FactoryBot.create(:administrator)
      mailing_list = FactoryBot.create(:mailing_list)
      post = FactoryBot.create(:post)

      Post.expects(:save).returns(true)
      Post.any_instance.expects(:save!).never

      put :update, params: { mailing_list_id: mailing_list.to_param, id: post.to_param, post: {
        from_name: "Mike Murray",
        from_email: "mmurray@obra.org",
        subject: "No More Masters Races",
        body: "That is all",
        "date(1i)" => "2009",
        "date(2i)" => "11",
        "date(3i)" => "22"
      }}
      assert_not_nil assigns(:post), @post
      assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
      assert_equal "No More Masters Races", assigns(:post).subject, "subject"
      assert_redirected_to edit_admin_mailing_list_post_path(mailing_list, assigns(:post))
    end

    test "destroy" do
      login_as FactoryBot.create(:administrator)
      mailing_list = FactoryBot.create(:mailing_list)

      original = FactoryBot.build(:post, mailing_list: mailing_list, subject: "My bike")
      Post.save original, mailing_list
      assert_equal 0, original.reload.replies_count, "replies_count"

      reply = FactoryBot.build(:post, mailing_list: mailing_list, subject: "Re: My bike", date: 10.minutes.ago)
      assert_equal 0, original.reload.replies_count, "replies_count"
      Post.save reply, mailing_list
      assert_equal 1, original.reload.replies_count, "replies_count"

      delete :destroy, params: { mailing_list_id: mailing_list.to_param, id: reply.to_param }
      assert_redirected_to admin_mailing_list_posts_path(mailing_list)
      assert !Post.exists?(reply.id), "Should delete Post"

      assert_equal 0, original.reload.replies_count, "replies_count"
    end
  end
end
