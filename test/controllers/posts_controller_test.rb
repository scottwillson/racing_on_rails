# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class PostsControllerTest < ActionController::TestCase
  test "index" do
    mailing_list = FactoryBot.create(:mailing_list)
    get :index, params: { mailing_list_id: mailing_list.id }
    assert_response :success
  end

  test "index atom" do
    mailing_list = FactoryBot.create(:mailing_list)
    get :index, params: { mailing_list_id: mailing_list.id, format: :atom }
    assert_response :success
  end

  test "index rss" do
    mailing_list = FactoryBot.create(:mailing_list)
    get :index, params: { mailing_list_id: mailing_list.id, format: :rss }
    assert_redirected_to format: :atom
  end

  test "index with date" do
    post = FactoryBot.create(:post)
    get :index, params: { mailing_list_id: post.mailing_list.id, month: 12, year: 2007 }
    assert_response :success
  end

  test "index with bogus date" do
    post = FactoryBot.create(:post)
    get :index, params: { mailing_list_id: post.mailing_list.id, month: 25, year: 7 }
    assert_response :success
  end

  test "index with bogus page" do
    post = FactoryBot.create(:post)
    get :index, params: { mailing_list_id: post.mailing_list.id, page: "atz" }
    assert_response :success
  end

  test "list" do
    obra_chat = FactoryBot.create(:mailing_list)
    (1..22).each do |index|
      date = Time.zone.now.beginning_of_month + index * 3600 * 24
      Post.create!(
        mailing_list: obra_chat,
        subject: "Subject Test #{index}",
        date: date,
        from_name: "Scout",
        from_email: "scout@obra.org",
        body: "This is a test message #{index}"
      )
    end

    obra_race = FactoryBot.create(:mailing_list)
    Post.create!(
      mailing_list: obra_race,
      subject: "Only OBRA Race Message",
      date: Time.zone.now,
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    get :index, params: { mailing_list_id: obra_chat.id }
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_equal(22, assigns["posts"].size, "Should show recent posts")

    get :index, params: { mailing_list_id: obra_race.id }
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(1, assigns["posts"].size, "Should show recent posts")
  end

  test "show" do
    obra_race = FactoryBot.create(:mailing_list)
    new_post = Post.create!(
      mailing_list: obra_race,
      subject: "Only OBRA Race Message",
      date: Time.zone.now,
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )
    new_post.save!

    get :show, params: { mailing_list_id: obra_race.id, id: new_post.id }
    assert_response(:success)
    assert_not_nil(assigns["post"], "Should assign post")
    assert_template("posts/show")
  end

  test "list with no lists" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :index
    end
  end

  test "list with bad name" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :index, params: { mailing_list_id: "Masters Racing" }
    end
  end
end
