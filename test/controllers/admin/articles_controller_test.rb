require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class ArticlesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    def test_create
      article_category = FactoryGirl.create(:article_category)
      post :create,
        :article => {
          :article_category_id => article_category.id,
          :display => true,
          :position => "1",
          :body => "<p><span style=\"font-size: small\"><span style=\"font-family: Arial\">So everyone is aware that your racing age for CX is the age on your 2010 license plus one.&nbsp; Since worlds are 29-30 Jan 2011, St Wendel, Germany, your racing age for the 2010/2011 season (per UCI and USAC) is your racing age in the year 2011.&nbsp; So if you&rsquo;re almost a master or almost not a junior, good news.&nbsp; It does affect those going to nationals or above.</span></span></p>\r\n<div style=\"margin: 0in 0in 0pt\"><o></o><span style=\"font-size: small\"><span style=\"font-family: Arial\">&nbsp;</span></span></div>\r\n<div style=\"margin: 0in 0in 0pt\"><span style=\"font-size: small\"><span style=\"font-family: Arial\">Mountain Bike, Road, and Collegiate licenses are all good for allowing you to race CX.&nbsp; Your CX category is annotated on your license.&nbsp; If you feel you should be higher or lower, provide me some justification and I&rsquo;ll review it.&nbsp; For road categories, you can get an automatic upgrade to your CX category to match your road category.&nbsp; MTB racers can also get an upgrade based on your category but it&rsquo;s not so clean cut.&nbsp; Be advised that if you get an upgrade, I&rsquo;ll be reluctant to downgrade your category for the remainder of the season.</span></span></div>\r\n<div style=\"margin: 0in 0in 0pt\"><o></o><span style=\"font-size: small\"><span style=\"font-family: Arial\">&nbsp;</span></span></div>\r\n<div style=\"margin: 0in 0in 0pt\"><span style=\"font-size: small\"><span style=\"font-family: Arial\">Good Luck to all in the upcoming season.</span></span></div>\r\n<p><o></o></p>"
      }

      assert_redirected_to admin_articles_url
    end
  end
end
