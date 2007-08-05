class InsertHomePageImages < ActiveRecord::Migration
  def self.up
    Image.create!(:name => 'home_page_photo', 
                 :html_options => ':height => 380, :width => 285', 
                 :link => "{:controller => 'results', :action => 'event', :id => 6162}",
                 :source => 'http://www.obra.org/images/photos/home_page.jpg',
                 :caption => "'Shanan Whitlatch celebrates her victory in the Vancouver Courthouse Criterium with Norrene Godfrey and Tina Brubaker (and her coach). &nbsp;&nbsp; Photo courtesy of Jon Kraft'")
    Image.create!(:name => 'home_page_ad_col_2_row_2', 
                  :html_options => ':height => 223, :width => 288', 
                  :link => "'http://www.bicycleattorney.com/'",
                  :source => 'http://www.obra.org/images/ads/mike_colbach.gif')
    end

  def self.down
    Image.delete_all
  end
end
