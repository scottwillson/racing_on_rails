# Homepage
class HomeController < ApplicationController
  caches_page :index
        
  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  # * recent_results: Events with Results within last two weeks
  def index
    @upcoming_events = UpcomingEvents.find_all(:weeks => 5)
#mbrahere to fix the above I had to create records in the disciplines table for each discipline hard coded in def disciplines_for(discipline)

    cutoff = Date.today - 14
    #mbratodo cutoff = Date.today - 28
    
    @recent_results = Event.find(:all,
      :select => "DISTINCT(events.id), events.name, events.parent_id, events.date, events.sanctioned_by",
      :joins => [:races => :results],
      :conditions => [
        'events.date > ? and events.sanctioned_by = ?', 
        cutoff, ASSOCIATION.short_name
#mbratodo: I used: :conditions => ['events.date > ? and standings.type is null', cutoff],
      ],
      :order => 'events.date desc'
    )

#mbrahere I added the following
    @news_category = ArticleCategory.find( :all, :conditions => ["name = 'news'"] )
    @recent_news = Article.find(
      :all,
      :conditions => ['updated_at > ? and article_category_id = ?', cutoff, @news_category],
      :order => 'updated_at desc'
    )

    render_page  
  end
  
  def auction
    @bid = Bid.highest
    render(:partial => 'auction')
  end
  
  def bid
    @highest_bid = Bid.highest
    @bid = Bid.new
  end
  
  def send_bid
    @bid = Bid.create(params[:bid])
    if @bid.errors.empty?
      begin
        BidMailer.create_created(@bid)
      rescue Exception => e
        logger.error("Could not send bid email notification: #{e}")
      end
      redirect_to :action => 'confirm_bid'
    else
      @highest_bid = Bid.highest
      render(:action => 'bid')
    end
  end
end
