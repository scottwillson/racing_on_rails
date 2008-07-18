require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'
require 'mailing_list_mailer'

# Re-raise errors caught by the controller.
class PostsController
  def rescue_action(e)
    raise e
  end
end

# FIXME Navigation tests are weak. Need to do more than just not blow up
class PostsControllerTest < ActiveSupport::TestCase

  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  def test_legacy_routing
    assert_recognizes(
      {:controller => "posts", :action => "show", :mailing_list_name => "obrarace", :id => "25621"}, 
      "posts/show/obrarace/25621"
    )
  
    assert_recognizes(
      {:controller => "posts", :action => "new", :mailing_list_name => "obra"}, 
      "posts/new/obra"
    )
  end
  
  def test_new
    obra_chat = mailing_lists(:obra_chat)
    get(:new, :mailing_list_name => obra_chat.name)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["mailing_list_post"], "Should assign mailing_list_post")
    mailing_list_post = assigns["mailing_list_post"]
    assert_equal(obra_chat, mailing_list_post.mailing_list, "Post's mailing list")
    assert_tag(:tag => "input", :attributes => {:type => "hidden", :name => "mailing_list_post[mailing_list_id]", :value => obra_chat.id})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[subject]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[from_email_address]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[from_name]"})
    assert_tag(:tag => "textarea", :attributes => {:name => "mailing_list_post[body]"})
    assert_tag(:tag => "input", :attributes => {:type => "submit", :name => "commit", :value => "Post"})
  end
  
  def test_new_reply
    obra_race = mailing_lists(:obra_race)
    original_post = Post.create({
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Date.today,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    get(:new, :mailing_list_name => obra_race.name, :reply_to => original_post.id)
    assert_response(:success)
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    mailing_list_post = assigns["mailing_list_post"]
    assert_not_nil(mailing_list_post, "Should assign mailing_list_post")
    assert_equal(original_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: Only OBRA Race Message", mailing_list_post.subject, 'Prepopulated subject')
    assert_equal(obra_race, mailing_list_post.mailing_list, "Post's mailing list")
    assert_tag(:tag => "input", :attributes => {:type => "hidden", :name => "mailing_list_post[mailing_list_id]", :value => obra_race.id})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[subject]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[from_email_address]"})
    assert_tag(:tag => "input", :attributes => {:type => "text", :name => "mailing_list_post[from_name]"})
    assert_tag(:tag => "textarea", :attributes => {:name => "mailing_list_post[body]"})
    assert_tag(:tag => "input", :attributes => {:type => "submit", :name => "commit", :value => "Send"})
  end
  
  def test_index_routing
    obra_chat = mailing_lists(:obra_chat)
    opts = {:controller => "posts", :action => "index", :mailing_list_name => obra_chat.name}
    assert_routing("posts/obra", opts)
  end
  
  def test_index
    get(:index, :mailing_list_name => "obrarace")
    assert_response(:redirect)
    assert_redirected_to(
      :action => "list", 
      :mailing_list_name => "obrarace", 
      :month => Date.today.month, 
      :year => Date.today.year
    )
  end
  
  def test_list
    obra_chat = mailing_lists(:obra_chat)
    for index in 1..22
      date = Time.now.beginning_of_month + index * 3600 * 24
      Post.create({
        :mailing_list => obra_chat,
        :subject => "Subject Test #{index}",
        :date => date,
        :from_name => "Scout",
        :from_email_address => "scout@obra.org",
        :body => "This is a test message #{index}"
      })
    end
  
    obra_race = mailing_lists(:obra_race)
    Post.create({
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => date,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    get(:list, :mailing_list_name => obra_chat.name, :month => Time.now.month, :year => Time.now.year)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["year"], "Should assign month")
    assert_not_nil(assigns["month"], "Should assign year")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(22, assigns["posts"].size, "Should show recent posts")
    assert_equal(Date.today.month, assigns["month"], "Assign month")
    assert_equal(Date.today.year, assigns["year"], "Assign year")
    assert_template("posts/list")
  
    get(:list, :mailing_list_name => obra_race.name, :month => Time.now.month, :year => Time.now.year)
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["year"], "Should assign month")
    assert_not_nil(assigns["month"], "Should assign year")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(1, assigns["posts"].size, "Should show recent posts")
    assert_equal(Date.today.month, assigns["month"], "Assign month")
    assert_equal(Date.today.year, assigns["year"], "Assign year")
    assert_template("posts/list")
  end
  
  def test_list_with_date
    obra_race = mailing_lists(:obra_race)
    post_2004_12_01 = Post.create({
      :mailing_list => obra_race,
      :subject => "BB 1 Race Results",
      :date => Date.new(2004, 12, 1),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    post_2004_11_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Cherry Pie Race Results",
      :date => Date.new(2004, 11, 30),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    post_2004_12_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Schedule Changes",
      :date => Time.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "11")
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["year"], "Should assign month")
    assert_not_nil(assigns["month"], "Should assign year")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(1, assigns["posts"].size, "Should show recent posts")
    assert_equal(11, assigns["month"], "Assign month")
    assert_equal(2004, assigns["year"], "Assign year")
    assert_equal(post_2004_11_31, assigns["posts"].first, "Post")
    assert_template("posts/list")
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "12")
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["year"], "Should assign month")
    assert_not_nil(assigns["month"], "Should assign year")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(2, assigns["posts"].size, "Should show recent posts")
    assert_equal(12, assigns["month"], "Assign month")
    assert_equal(2004, assigns["year"], "Assign year")
    assert_equal(post_2004_12_31, assigns["posts"].first, "Post")
    assert_equal(post_2004_12_01, assigns["posts"].last, "Post")
    assert_template("posts/list")
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "10")
    assert_response(:success)
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    assert_not_nil(assigns["year"], "Should assign month")
    assert_not_nil(assigns["month"], "Should assign year")
    assert_not_nil(assigns["posts"], "Should assign posts")
    assert_equal(10, assigns["month"], "Assign month")
    assert_equal(2004, assigns["year"], "Assign year")
    assert(assigns["posts"].empty?, "No posts")
    assert_template("posts/list")
  end
  
  def test_list_previous_next
    obra_race = mailing_lists(:obra_race)
    post_2004_12_01 = Post.create({
      :mailing_list => obra_race,
      :subject => "BB 1 Race Results",
      :date => Date.new(2004, 12, 1),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    post_2004_11_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Cherry Pie Race Results",
      :date => Date.new(2004, 11, 30),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    post_2004_12_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Schedule Changes",
      :date => Time.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "11", :next => "&gt;")
    assert_response(:redirect)
    assert_redirected_to(:month => 12, :year => 2004)
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "12", :next => "&gt;")
    assert_response(:redirect)
    assert_redirected_to(:month => 1, :year => 2005)
    
    get(:list, :mailing_list_name => obra_race.name, :year => "2004", :month => "12", :previous => "&lt;")
    assert_response(:redirect)
    assert_redirected_to(:month => 11, :year => 2004)
  end
  
  def test_list_routing
    path = {:controller => "posts", :action => "list", :mailing_list_name => "obra", :year => "2003", :month => "8"}
    assert_routing("posts/obra/2003/8", path)
  end
  
  def test_post
    assert(MailingListMailer.deliveries.empty?, "Should have no email deliveries")
  
    obra_chat = mailing_lists(:obra_chat)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email_address = "tim.schauer@butlerpress.com"
    body = "Barely used"
  
    path = {:controller => "posts", :action => "post", :mailing_list_name => 'obra'}
    assert_routing("posts/obra/post", path)
  
    post(:post, 
        :mailing_list_name => obra_chat.name,
        :reply_to => {:id => ''},
        :mailing_list_post => {
          :mailing_list_id => obra_chat.id,
          :subject => subject, 
          :from_name => from_name,
          :from_email_address => from_email_address,
          :body => body},
        :commit => "Post"
    )
    
    assert(flash.has_key?(:notice))
    assert_response(:redirect)
    assert_redirected_to(:action => "confirm", :mailing_list_name => obra_chat.name)
    
    assert_equal(1, MailingListMailer.deliveries.size, "Should have one email delivery")
    delivered_mail = MailingListMailer.deliveries.first
    assert_equal(subject, delivered_mail.subject, "Subject")
    assert_equal([from_email_address], delivered_mail.from, "From email")
    assert_equal(from_name, delivered_mail.friendly_from, "From Name")
    assert_equal_dates(Date.today, delivered_mail.date, "Date")
    assert_equal([obra_chat.name], delivered_mail.to, "Recipient")
  end
  
  def test_post_reply
    assert(MailingListMailer.deliveries.empty?, "Should have no email deliveries")
  
    obra_chat = mailing_lists(:obra_chat)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email_address = "tim.schauer@butlerpress.com"
    body = "Barely used"
    reply_to_post = Post.create({
      :mailing_list => obra_chat,
      :subject => "Schedule Changes",
      :date => Time.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    path = {:controller => "posts", :action => "post", :mailing_list_name => 'obra'}
    assert_routing("posts/obra/post", path)
  
    post(:post, 
        :mailing_list_name => obra_chat.name,
        :mailing_list_post => {
          :mailing_list_id => obra_chat.id,
          :subject => subject, 
          :from_name => from_name,
          :from_email_address => from_email_address,
          :body => body},
        :reply_to => {:id => reply_to_post.id},
        :commit => "Post"
    )
    
    assert(flash.has_key?(:notice))
    assert_response(:redirect)
    assert_redirected_to(:action => "confirm_private_reply", :mailing_list_name => obra_chat.name)
    
    assert_equal(1, MailingListMailer.deliveries.size, "Should have one email delivery")
    delivered_mail = MailingListMailer.deliveries.first
    assert_equal(subject, delivered_mail.subject, "Subject")
    assert_equal([from_email_address], delivered_mail.from, "From email")
    assert_equal(from_name, delivered_mail.friendly_from, "From Name")
    assert_equal_dates(Date.today, delivered_mail.date, "Date")
    assert_equal(['scout@obra.org'], delivered_mail.to, "Recipient")
  end
  
  def test_post_invalid_reply
    obra_chat = mailing_lists(:obra_chat)
    subject = "Spynergy for Sale"
    from_name = "Tim Schauer"
    from_email_address = "tim.schauer@butlerpress.com"
    body = "Barely used"
    reply_to_post = Post.create!(
      :mailing_list => obra_chat,
      :subject => "Schedule Changes",
      :date => Time.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    )
  
    post(:post, 
        :mailing_list_name => obra_chat.name,
        :mailing_list_post => {
          :mailing_list_id => obra_chat.id,
          :subject => "Re: #{subject}", 
          :from_name => "",
          :from_email_address => "",
          :body => ""},
        :reply_to => {:id => reply_to_post.id},
        :commit => "Send"
    )
    
    assert_template("posts/new")
    assert_not_nil(assigns["mailing_list"], "Should assign mailing_list")
    mailing_list_post = assigns["mailing_list_post"]
    assert_not_nil(mailing_list_post, "Should assign mailing_list_post")
    assert_equal(reply_to_post, assigns["reply_to"], "Should assign reply_to")
    assert_equal("Re: #{subject}", mailing_list_post.subject, 'Prepopulated subject')
    assert_equal(obra_chat, mailing_list_post.mailing_list, "Post's mailing list")
  end
  
  def test_confirm
    obra_race = mailing_lists(:obra_race)
    path = {:controller => "posts", :action => "confirm", :mailing_list_name => obra_race.name }
    assert_routing("posts/obrarace/confirm", path)
  
    get(:confirm, :mailing_list_name => obra_race.name)
    assert_response(:success)
    assert_template("posts/confirm")
    assert_equal(obra_race, assigns["mailing_list"], 'Should assign mailing list')
  end
  
  def test_confirm_private_reply
    obra_race = mailing_lists(:obra_race)
    path = {:controller => "posts", :action => "confirm_private_reply", :mailing_list_name => obra_race.name }
    assert_routing("posts/obrarace/confirm_private_reply", path)
  
    get(:confirm_private_reply, :mailing_list_name => obra_race.name)
    assert_response(:success)
    assert_template("posts/confirm_private_reply")
    assert_equal(obra_race, assigns["mailing_list"], 'Should assign mailing list')
  end
  
  def test_show
    obra_race = mailing_lists(:obra_race)
    new_post = Post.create({
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Time.now,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    new_post.save!
  
    path = {:controller => "posts", :action => "show", :mailing_list_name => obra_race.name, :id => new_post.id.to_s }
    assert_routing("posts/obrarace/show/#{new_post.id}", path)
  
    get(:show, :mailing_list_name => obra_race.name, :id => new_post.id)
    assert_response(:success)
    assert_not_nil(assigns["post"], "Should assign post")
    assert_template("posts/show")
  end
  
  def test_archive_navigation
    # No posts
    get(:list, :mailing_list_name => "obrarace", :year => "2004", :month => "12")
    assert_tag(:tag => "div", :attributes => {:class => "archive_navigation"})
  
    # One post
    obra_race = mailing_lists(:obra_race)
    new_post = Post.create({
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Time.local(2004, 12, 31, 12, 30),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    get(:list, :mailing_list_name => "obrarace", :year => "2004", :month => "12")
    assert_tag(:tag => "div", :attributes => {:class => "archive_navigation"})
  
    # Two months
    obra_race = mailing_lists(:obra_race)
    new_post = Post.create({
      :mailing_list => obra_race,
      :subject => "Before OBRA Race Message",
      :date => Time.local(2004, 11, 7),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    get(:list, :mailing_list_name => "obrarace", :year => "2004", :month => "11")
    assert_tag(:tag => "div", :attributes => {:class => "archive_navigation"})
  end
  
  def test_post_navigation
    # One post
    obra_race = mailing_lists(:obra_race)
    post_2004_12_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Only OBRA Race Message",
      :date => Time.local(2004, 12, 31, 12, 30),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    get(:show, :mailing_list_name => obra_race.name, :id => post_2004_12_31.id)
  
    # Two months
    post_2004_11_07 = Post.create({
      :mailing_list => obra_race,
      :subject => "Before OBRA Race Message",
      :date => Time.local(2004, 11, 7),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    get(:show, :mailing_list_name => obra_race.name, :id => post_2004_12_31.id)
  
    # Three months
    post_2004_11_03 = Post.create({
      :mailing_list => obra_race,
      :subject => "Before OBRA Race Message",
      :date => Time.local(2004, 11, 3, 8, 00, 00),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    get(:show, :mailing_list_name => obra_race.name, :id => post_2004_11_07.id)
    
    # Another list
    obra_chat = mailing_lists(:obra_chat)
    post_other_list = Post.create({
      :mailing_list => obra_chat,
      :subject => "OBRA Chat",
      :date => Time.local(2004, 11, 3, 21, 00, 00),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    
    get(:show, :mailing_list_name => obra_race.name, :id => post_2004_11_07.id)
    assert_tag(:tag => "div", :attributes => {:class => "archive_navigation"})
  end
  
  def test_post_previous_next
    obra_race = mailing_lists(:obra_race)
    post_2004_12_01 = Post.create({
      :mailing_list => obra_race,
      :subject => "BB 1 Race Results",
      :date => Time.local(2004, 12, 1),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
  
    post_2004_11_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Cherry Pie Race Results",
      :date => Time.local(2004, 11, 30),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    post_2004_12_31 = Post.create({
      :mailing_list => obra_race,
      :subject => "Schedule Changes",
      :date => Time.local(2004, 12, 31, 23, 59, 59, 999999),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    
    get(:show, :mailing_list_name => obra_race.name, :next_id => post_2004_12_31.id, :next => "&gt;")
    assert_response(:redirect)
    assert_redirected_to(:id => post_2004_12_31.id.to_s)
  
    get(:show, :mailing_list_name => obra_race.name, :previous_id => post_2004_11_31.id, :previous => "&lt;")
    assert_response(:redirect)
    assert_redirected_to(:id => post_2004_11_31.id.to_s)

    # This part doesn't prove much
    obra_chat = mailing_lists(:obra_chat)
    post_other_list = Post.create({
      :mailing_list => obra_chat,
      :subject => "OBRA Chat",
      :date => Time.local(2004, 12, 31, 12, 00, 00),
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message."
    })
    
    get(:show, :mailing_list_name => obra_race.name, :next_id => post_2004_12_31.id, :next => "&gt;")
    assert_response(:redirect)
    assert_redirected_to(:id => post_2004_12_31.id.to_s)
  end
  
  def test_list_with_no_lists
    MailingList.delete_all
    get(:list, :month => Date.today.month, :year => Date.today.year)
    assert_response(:success)
    assert_template('404')
    assert(!flash.empty?, "Should have flash")
  end
  
  def test_list_with_bad_name
    get(:list, :month => Date.today.month, :year => Date.today.year, :mailing_list_name => "Masters Racing")
    assert_response(:success)
    assert_template('404')
    assert(!flash.empty?, "Should have flash")
  end
  
  def test_list_with_bad_month
    get(:list, :month => 14, :year => Date.today.year, :mailing_list_name => mailing_lists(:obra_race).name)
    assert_redirected_to(
      :action => "list", 
      :mailing_list_name => "obrarace", 
      :month => Date.today.month, 
      :year => Date.today.year
    )
  end
  
  def test_list_with_bad_year
    get(:list, :month => 12, :year => 9_116_560, :mailing_list_name => mailing_lists(:obra_race).name)
    assert_redirected_to(
      :action => "list", 
      :mailing_list_name => "obrarace", 
      :month => Date.today.month, 
      :year => Date.today.year
    )
  end
end
