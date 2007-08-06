class InsertNews < ActiveRecord::Migration
  def self.up
    NewsItem.create(:date => Date.new(2007, 2, 5), :text => 'Teams, please check <a href="teams/rides.html">club ride list</a>. <a href="mailto:cjw@cheryljwillson.com">Email</a> with additions or corrections for 2007.')
    NewsItem.create(:date => Date.new(2007, 2, 5), :text => '2007 license application is on the <a href="forms/index.html">forms page</a> and <a href="https://www.signmeup.com/site/reg/register.aspx?fid=L32VHK7">online</a>.')
    NewsItem.create(:date => Date.new(2007, 2, 5), :text => 'Did your team renew for 2007? Being an OBRA registered team allows your team to <br>compete in the 2007 team BAR competition. The club membership application is on<br> the <a href="forms/index.html">forms page</a>.')
    NewsItem.create(:date => Date.new(2007, 5, 24), :text => 'Phil Sanders celebrated his 76th birthday at Alpenrose. See the <a href="http://www.teamrosecity.org/images/events/EK2007/EK-07-Phil-Sanders-BD.jpg">evidence</a>!')
    NewsItem.create(:date => Date.new(2007, 5, 30), :text => 'Keep track of Ryan McKnab\'s condition or make a contribution through <a href="http://www.ryanmcknab.blogspot.com">this blog</a> or visit the <a href="http://www.caringbridge.org/cb/visitAPage.do">CaringBridge site</a> (login ryanmcknab )')
    NewsItem.create(:date => Date.new(2007, 6, 18), :text => 'A trail guide is now available for the Oakridge Fat Tire Festival. (<a href="pdfs/FTF_Trail_Guide.pdf">694 KB PDF</a>)')
  end

  def self.down
  end
end
