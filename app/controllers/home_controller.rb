# Homepage
class HomeController < ApplicationController
  model :discipline
  caches_page :index
        
  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  # * recent_results: Events with Results within last two weeks
  def index
    @upcoming_events = UpcomingEvents.new
    
    cutoff = Date.today - 14
    @recent_results = SingleDayEvent.find(
      :all,
      :conditions => ['date > ? and id in (select event_id from standings)', cutoff],
      :order => 'date desc'
    )
    
    @news = NewsItem.find(:all)
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
