require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PostsControllerTest < ActionController::TestCase
  test "new" do
    obra_chat = FactoryGirl.create(:mailing_list)
    get(:new, mailing_list_id: obra_chat.id)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["post"], "Should assign post")
    post = assigns["post"]
    assert_equal(obra_chat, post.mailing_list, "Post's mailing list")
    assert_tag(tag: "input", attributes: {type: "text", name: "post[subject]"})
    assert_tag(tag: "input", attributes: {type: "text", name: "post[from_email]"})
    assert_tag(tag: "input", attributes: {type: "text", name: "post[from_name]"})
    assert_tag(tag: "textarea", attributes: {name: "post[body]"})
    assert_tag(tag: "input", attributes: {type: "submit", name: "commit", value: "Post"})
  end

  test "new reply" do
    obra_race = FactoryGirl.create(:mailing_list)
    original_post = Post.create!(
      mailing_list: obra_race,
      subject: "Only OBRA Race Message",
      date: Time.zone.today,
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    get(:new, mailing_list_id: obra_race.id, reply_to_id: original_post.id)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    post = assigns["post"]
    assert_not_nil(post, "Should assign post")
    assert_equal(original_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: Only OBRA Race Message", post.subject, 'Prepopulated subject')
    assert_equal(obra_race, post.mailing_list, "Post's mailing list")
    assert_tag(tag: "input", attributes: {type: "text", name: "post[subject]"})
    assert_tag(tag: "input", attributes: {type: "text", name: "post[from_email]"})
    assert_tag(tag: "input", attributes: {type: "text", name: "post[from_name]"})
    assert_tag(tag: "textarea", attributes: {name: "post[body]"})
    assert_tag(tag: "input", attributes: {type: "submit", name: "commit", value: "Send"})
  end

  test "index" do
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, mailing_list_id: mailing_list.id
    assert_response :success
  end

  test "index atom" do
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, mailing_list_id: mailing_list.id, format: :atom
    assert_response :success
  end

  test "index rss" do
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, mailing_list_id: mailing_list.id, format: :rss
    assert_redirected_to format: :atom
  end

  test "index with date" do
    post = FactoryGirl.create(:post)
    get :index, mailing_list_id: post.mailing_list.id, month: 12, year: 2007
    assert_response :success
  end

  test "index with bogus date" do
    post = FactoryGirl.create(:post)
    get :index, mailing_list_id: post.mailing_list.id, month: 25, year: 7
    assert_response :success
  end

  test "index with bogus page" do
    post = FactoryGirl.create(:post)
    get :index, mailing_list_id: post.mailing_list.id, page: "atz"
    assert_response :success
  end

  test "list" do
    obra_chat = FactoryGirl.create(:mailing_list)
    for index in 1..22
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

    obra_race = FactoryGirl.create(:mailing_list)
    Post.create!(
      mailing_list: obra_race,
      subject: "Only OBRA Race Message",
      date: date,
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    get(:index, mailing_list_id: obra_chat.id)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_equal(22, assigns["posts"].size, "Should show recent posts")

    get(:index, mailing_list_id: obra_race.id)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(1, assigns["posts"].size, "Should show recent posts")
  end

  test "post" do
    MailingListMailer.deliveries.clear

    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"

    post(:create,
        mailing_list_id: obra_chat.to_param,
        reply_to_id: '',
        post: {
          subject: subject,
          from_name: from_name,
          from_email: from_email,
          body: body},
        commit: "Post"
    )

    assert_not_nil flash[:notice]
    assert_redirected_to mailing_list_confirm_path(obra_chat)

    assert_equal(1, MailingListMailer.deliveries.size, "Should have one email delivery")
    delivered_mail = MailingListMailer.deliveries.first
    assert_equal(subject, delivered_mail.subject, "Subject")
    assert_equal([from_email], delivered_mail.from, "From email")
    assert_equal(from_name, delivered_mail[:from].display_names.first, "From Name")
    assert_equal_dates(Time.zone.now.utc, delivered_mail.date.utc, "Date")
    assert_equal([obra_chat.name], delivered_mail.to, "Recipient")
  end

  test "post reply" do
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
    reply_to_post = Post.create!(
      mailing_list: obra_chat,
      subject: "Schedule Changes",
      date: Time.zone.local(2004, 12, 31, 23, 59, 59, 999999),
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    assert_no_difference "Post.count" do
      post(:create,
          mailing_list_id: obra_chat.id,
          post: {
            subject: subject,
            from_name: from_name,
            from_email: from_email,
            body: body},
          reply_to_id: reply_to_post.id,
          commit: "Post"
      )
    end

    assert_not_nil flash[:notice]
    assert_response(:redirect)
    assert_redirected_to mailing_list_confirm_private_reply_path(obra_chat)

    delivered_mail = MailingListMailer.deliveries.last
    assert_equal(subject, delivered_mail.subject, "Subject")
    assert_equal([from_email], delivered_mail.from, "From email")
    assert_equal(from_name, delivered_mail[:from].display_names.first, "From Name")
    assert_equal_dates(Time.zone.now.utc, delivered_mail.date.utc, "Date")
    assert_equal(['scout@obra.org'], delivered_mail.to, "Recipient")
  end

  test "post invalid reply" do
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    reply_to_post = Post.create!(
      mailing_list: obra_chat,
      subject: "Schedule Changes",
      date: Time.zone.local(2004, 12, 31, 23, 59, 59, 999999),
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    post(:create,
        mailing_list_id: obra_chat.to_param,
        post: {
          subject: "Re: #{subject}",
          from_name: "",
          from_email: "",
          body: ""},
        reply_to_id: reply_to_post.id,
        commit: "Send"
    )

    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    post = assigns["post"]
    assert_not_nil(post, "Should assign post")
    assert_equal(reply_to_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: #{subject}", post.subject, 'Prepopulated subject')
    assert_equal(obra_chat, post.mailing_list, "Post's mailing list")
  end

  test "post smtp 502 error" do
    MailingListMailer.deliveries.clear

    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"

    Mail::Message.any_instance.expects(:deliver).raises(Net::SMTPFatalError, "502 5.5.2 Error: command not recognized")
    post(:create,
        mailing_list_id: obra_chat.to_param,
        reply_to_id: '',
        post: {
          subject: subject,
          from_name: from_name,
          from_email: from_email,
          body: body},
        commit: "Post"
    )

    assert_not_nil flash[:warn]
    assert_response :success

    assert_equal(0, MailingListMailer.deliveries.size, "Should have no email deliveries")
  end

  test "post smtp 5450 error" do
    MailingListMailer.deliveries.clear

    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"

    Mail::Message.any_instance.expects(:deliver).raises(Net::SMTPServerBusy, "450 4.1.8 <wksryz@rxrzdj.com>: Sender address rejected: Domain not found")
    post(:create,
        mailing_list_id: obra_chat.to_param,
        reply_to_id: '',
        post: {
          subject: subject,
          from_name: from_name,
          from_email: from_email,
          body: body},
        commit: "Post"
    )

    assert_not_nil flash[:warn]
    assert_response :success

    assert_equal(0, MailingListMailer.deliveries.size, "Should have no email deliveries")
  end

  test "show" do
    obra_race = FactoryGirl.create(:mailing_list)
    new_post = Post.create!(
      mailing_list: obra_race,
      subject: "Only OBRA Race Message",
      date: Time.zone.now,
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )
    new_post.save!

    get(:show, mailing_list_id: obra_race.id, id: new_post.id)
    assert_response(:success)
    assert_not_nil(assigns["post"], "Should assign post")
    assert_template("posts/show")
  end

  test "list with no lists" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:index)
    end
  end

  test "list with bad name" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:index, mailing_list_id: "Masters Racing")
    end
  end

  test "spam post should not cause error" do
    obra_chat = FactoryGirl.create(:mailing_list)
    post(:create, { "commit" => "Post", "mailing_list_id" => obra_chat.to_param,
                  "post" => { "from_name" => "strap",
                               "body" => "<a href= http://www.blogextremo.com/elroybrito >strap on gallery</a> <a href= http://emmittmcclaine.blogownia.pl >lesbian strap on</a> <a href= http://www.cherryade.com/margenemohabeer >strap on sex</a> ",
                               "subject" => "onstrapdildo@mail.com",
                               "from_email" => "onstrapdildo@mail.com"}
    })
    assert_response(:redirect)
  end
end
