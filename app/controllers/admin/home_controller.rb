class Admin::HomeController < ApplicationController

  before_filter :login_required

  def index
    @upcoming_events = UpcomingEvents.new
    
    cutoff = Date.today - 14
    @recent_results = SingleDayEvent.find(
      :all,
      :conditions => ['date > ? and id in (select event_id from standings)', cutoff],
      :order => 'date desc'
    )
    
    @news = NewsItem.find(:all)
    @home_page_photo = Image.find_by_name('home_page_photo')
  end
end
