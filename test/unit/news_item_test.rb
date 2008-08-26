require File.dirname(__FILE__) + '/../test_helper'

class NewsItemTest < ActiveSupport::TestCase
  def test_create
    news_item = NewsItem.create!(:text => 'The British are coming')
    assert_equal_dates(Date.today, news_item.date, 'Date should default to today')

    news_item = NewsItem.create!(:text => 'The British are coming', :date => Date.new(2009, 10, 2))
    assert_equal_dates(Date.new(2009, 10, 2), news_item.date, 'Date after create')
  end
  
  def test_validation
    assert(NewsItem.new(:text => 'news text').valid?, 'NewsItem with text and no date should be valid')
    assert(NewsItem.new(:date => Date.new(2009, 10, 2), :text => 'news text').valid?, 'NewsItem with text and date should be valid')
    assert(!NewsItem.new.valid?, 'NewsItem with no text and no date should not be valid')
    assert(!NewsItem.new(:date => Date.new(2009, 10, 2)).valid?, 'NewsItem with no text and date should not be valid')
  end
end
