class Admin::HomeController < ApplicationController

  before_filter :login_required

  def index
    @upcoming_events = UpcomingEvents.new
    
    cutoff = Date.today - 14
    @recent_results = Standings.find(
      :all,
      :include => :event,
      :conditions => ['events.date > ? and events.sanctioned_by = ? and standings.type is null', cutoff, ASSOCIATION.short_name],
      :order => 'events.date desc'
    )
    
    @news = NewsItem.find(:all)
    @home_page_photo = Image.find_by_name('home_page_photo')
    if @home_page_photo.nil?
      @home_page_photo = Image.create(:name => 'home_page_photo', :source => 'images/spacer.gif')
    end
  end
end
