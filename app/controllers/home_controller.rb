# Homepage
class HomeController < ApplicationController
  caches_page :index
        
  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  # * recent_results: Events with Results within last two weeks
  def index
    @upcoming_events = UpcomingEvents.find_all(:weeks => WEEKS_OF_UPCOMING_EVENTS)

    cutoff = Date.today - WEEKS_OF_RECENT_RESULTS * 7
    
    @recent_results = Event.find(:all,
      :select => "DISTINCT(events.id), events.name, events.parent_id, events.date, events.sanctioned_by",
      :joins => [:races => :results],
      :conditions => [
        'events.date > ? and events.sanctioned_by = ?', 
        cutoff, RacingAssociation.current.default_sanctioned_by
      ],
      :order => 'events.date desc'
    )

    @news_category = ArticleCategory.find( :all, :conditions => ["name = 'news'"] )
    @recent_news = Article.find(
      :all,
      :conditions => ['created_at > ? and article_category_id = ?', cutoff, @news_category],
      :order => 'created_at desc'
    )

    render_page  
  end
end
