require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PostsControllerTest < ActionController::TestCase
  assert_no_angle_brackets :except => [ :all ]
  
  def test_new
    obra_chat = FactoryGirl.create(:mailing_list)
    get(:new, :mailing_list_id => obra_chat.id)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["post"], "Should assign post")
    post = assigns["post"]
    assert_equal(obra_chat, post.mailing_list, "Post's mailing list")
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[subject]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[from_email]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[from_name]"})
    assert_tag(:tag => "textarea", :attributes => {:name => "post[body]"})
    assert_tag(:tag => "input", :attributes => {:type => "submit", :name => "commit", :value => "Post"})
  end
  
  def test_new_reply
    obra_race = FactoryGirl.create(:mailing_list)
    original_post = Post.create!(
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Time.zone.today,
      :from_name => "Scout",
      :from_email => "scout@obra.org",
      :body => "This is a test message."
    )
  
    get(:new, :mailing_list_id => obra_race.id, :reply_to_id => original_post.id)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    post = assigns["post"]
    assert_not_nil(post, "Should assign post")
    assert_equal(original_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: Only OBRA Race Message", post.subject, 'Prepopulated subject')
    assert_equal(obra_race, post.mailing_list, "Post's mailing list")
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[subject]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[from_email]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "post[from_name]"})
    assert_tag(:tag => "textarea", :attributes => {:name => "post[body]"})
    assert_tag(:tag => "input", :attributes => {:type => "submit", :name => "commit", :value => "Send"})
  end
  
  def test_blank_search
    mailing_list = FactoryGirl.create(:mailing_list)
    FactoryGirl.create_list(:post, 3, :mailing_list => mailing_list)
    get :index, :mailing_list_id => mailing_list.id, :subject => ""
    assert_response :success
    assert_equal 3, assigns[:posts].size, "Should return all posts"
  end
  
  def test_matching_search
    mailing_list = FactoryGirl.create(:mailing_list)
    FactoryGirl.create_list(:post, 3, :mailing_list => mailing_list)
    post = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "Cervelo for sale")
    get :index, :mailing_list_id => mailing_list.id, :subject => "Cervelo"
    assert_response :success
    assert_equal [ post ], assigns[:posts], "Should search by subject posts"
  end
  
  def test_no_matching_search
    mailing_list = FactoryGirl.create(:mailing_list)
    FactoryGirl.create_list(:post, 3, :mailing_list => mailing_list)
    post = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "Paging Todd Littlehales")
    get :index, :mailing_list_id => mailing_list.id, :subject => "Cervelo"
    assert_response :success
    assert assigns[:posts].empty?, "Should search by subject posts"
  end
  
  def test_index
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, :mailing_list_id => mailing_list.id
    assert_response :success
  end
  
  def test_index_atom
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, :mailing_list_id => mailing_list.id, :format => :atom
    assert_response :success
  end
  
  def test_index_rss
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, :mailing_list_id => mailing_list.id, :format => :rss
    assert_redirected_to :format => :atom
  end
  
  def test_index_with_date
    post = FactoryGirl.create(:post)
    get :index, :mailing_list_id => post.mailing_list.id, :month => 12, :year => 2007
    assert_response :success
  end
  
  def test_index_with_bogus_date
    post = FactoryGirl.create(:post)
    get :index, :mailing_list_id => post.mailing_list.id, :month => 25, :year => 7
    assert_response :success
  end
  
  def test_index_with_bogus_page
    post = FactoryGirl.create(:post)
    get :index, :mailing_list_id => post.mailing_list.id, :page => "atz"
    assert_response :success
  end
  
  def test_list
    obra_chat = FactoryGirl.create(:mailing_list)
    for index in 1..22
      date = Time.zone.now.beginning_of_month + index * 3600 * 24
      Post.create!(
        :mailing_list => obra_chat,
        :subject => "Subject Test #{index}",
        :date => date,
        :from_name => "Scout",
        :from_email => "scout@obra.org",
        :body => "This is a test message #{index}"
      )
    end
  
    obra_race = FactoryGirl.create(:mailing_list)
    Post.create!(
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => date,
      :from_name => "Scout",
      :from_email => "scout@obra.org",
      :body => "This is a test message."
    )
  
    get(:index, :mailing_list_id => obra_chat.id)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_equal(22, assigns["posts"].size, "Should show recent posts")
  
    get(:index, :mailing_list_id => obra_race.id)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(1, assigns["posts"].size, "Should show recent posts")
  end
  
  def test_post
    MailingListMailer.deliveries.clear
  
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
  
    post(:create, 
        :mailing_list_id => obra_chat.to_param,
        :reply_to_id => '',
        :post => {
          :subject => subject, 
          :from_name => from_name,
          :from_email => from_email,
          :body => body},
        :commit => "Post"
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
  
  def test_post_reply
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
    reply_to_post = Post.create!(
      :mailing_list => obra_chat,
      :subject => "Schedule Changes",
      :date => Time.zone.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email => "scout@obra.org",
      :body => "This is a test message."
    )
  
    assert_no_difference "Post.count" do
      post(:create, 
          :mailing_list_id => obra_chat.id,
          :post => {
            :subject => subject, 
            :from_name => from_name,
            :from_email => from_email,
            :body => body},
          :reply_to_id => reply_to_post.id,
          :commit => "Post"
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
  
  def test_post_invalid_reply
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
    reply_to_post = Post.create!(
      :mailing_list => obra_chat,
      :subject => "Schedule Changes",
      :date => Time.zone.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email => "scout@obra.org",
      :body => "This is a test message."
    )
  
    post(:create, 
        :mailing_list_id => obra_chat.to_param,
        :post => {
          :subject => "Re: #{subject}", 
          :from_name => "",
          :from_email => "",
          :body => ""},
        :reply_to_id => reply_to_post.id,
        :commit => "Send"
    )
    
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    post = assigns["post"]
    assert_not_nil(post, "Should assign post")
    assert_equal(reply_to_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: #{subject}", post.subject, 'Prepopulated subject')
    assert_equal(obra_chat, post.mailing_list, "Post's mailing list")
  end
  
  def test_post_smtp_502_error
    MailingListMailer.deliveries.clear
  
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
  
    Mail::Message.any_instance.expects(:deliver).raises(Net::SMTPFatalError, "502 5.5.2 Error: command not recognized")
    post(:create, 
        :mailing_list_id => obra_chat.to_param,
        :reply_to_id => '',
        :post => {
          :subject => subject, 
          :from_name => from_name,
          :from_email => from_email,
          :body => body},
        :commit => "Post"
    )
    
    assert_not_nil flash[:warn]
    assert_response :success
    
    assert_equal(0, MailingListMailer.deliveries.size, "Should have no email deliveries")
  end
  
  def test_post_smtp_5450_error
    MailingListMailer.deliveries.clear
  
    obra_chat = FactoryGirl.create(:mailing_list)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email = "tim.schauer@butlerpress.com"
    body = "Barely used"
  
    Mail::Message.any_instance.expects(:deliver).raises(Net::SMTPServerBusy, "450 4.1.8 <wksryz@rxrzdj.com>: Sender address rejected: Domain not found")
    post(:create, 
        :mailing_list_id => obra_chat.to_param,
        :reply_to_id => '',
        :post => {
          :subject => subject, 
          :from_name => from_name,
          :from_email => from_email,
          :body => body},
        :commit => "Post"
    )
    
    assert_not_nil flash[:warn]
    assert_response :success
    
    assert_equal(0, MailingListMailer.deliveries.size, "Should have no email deliveries")
  end
  
  def test_show
    obra_race = FactoryGirl.create(:mailing_list)
    new_post = Post.create!(
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Time.zone.now,
      :from_name => "Scout",
      :from_email => "scout@obra.org",
      :body => "This is a test message."
    )
    new_post.save!
  
    get(:show, :mailing_list_id => obra_race.id, :id => new_post.id)
    assert_response(:success)
    assert_not_nil(assigns["post"], "Should assign post")
    assert_template("posts/show")
  end
  
  def test_list_with_no_lists
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:index)
    end
  end
  
  def test_list_with_bad_name
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:index, :mailing_list_id => "Masters Racing")
    end
  end

  def test_spam_post_should_not_cause_error
    obra_chat = FactoryGirl.create(:mailing_list)
    post(:create, { "commit"=>"Post", "mailing_list_id"=> obra_chat.to_param, 
                  "post" => { "from_name"=>"strap", 
                               "body"=>"<a href= http://www.blogextremo.com/elroybrito >strap on gallery</a> <a href= http://emmittmcclaine.blogownia.pl >lesbian strap on</a> <a href= http://www.cherryade.com/margenemohabeer >strap on sex</a> ", 
                               "subject"=>"onstrapdildo@mail.com", 
                               "from_email"=>"onstrapdildo@mail.com"}
    })
    assert_response(:redirect)
  end
end
