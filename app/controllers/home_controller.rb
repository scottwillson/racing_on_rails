# Homepage
class HomeController < ApplicationController
  respond_to :html

  caches_page :index

  before_filter :require_administrator, except: :index

  # Show homepage
  # === Assigns
  # * upcoming_events
  # * recent_results: Events with Results within last two weeks
  def index
    assign_home

    @page_title = RacingAssociation.current.name

    @upcoming_events = Event.upcoming(@home.weeks_of_upcoming_events)

    @events_with_recent_results = Event.
      includes(parent: :parent).
      where("type != ?", "Event").
      where("type is not null").
      where("events.date >= ?", @home.weeks_of_recent_results.weeks.ago).
      where("id in (select event_id from results where competition_result = false and team_competition_result = false)").
      order("updated_at desc")

    if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?
      @events_with_recent_results = @events_with_recent_results.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
    end

    @most_recent_event_with_recent_result = Event.
      includes(races: [ :category, :results ]).
      includes(:parent).
      where("type != ?", "Event").
      where("type is not null").
      where("events.date >= ?", @home.weeks_of_recent_results.weeks.ago).
      where(sanctioned_by: RacingAssociation.current.default_sanctioned_by).
      where("id in (select event_id from results where competition_result = false and team_competition_result = false)").
      order("updated_at desc").
      first

    @news_category = ArticleCategory.where(name: "news").first
    if @news_category
      @recent_news = Article.recent_news(@home.weeks_of_upcoming_events.weeks.ago, @news_category)
    end

    @photo = @home.photo
    @posts = recent_posts

    render_page
  end

  def edit
    assign_home
  end

  def update
    assign_home
    if @home.update(home_params)
      expire_cache
      redirect_to edit_home_path
    else
      render :edit
    end
  end

  private

  def assign_home
    @home = Home.current
  end

  def home_params
    params_without_mobile.require(:home).permit(:photo_id, :weeks_of_recent_results, :weeks_of_upcoming_events)
  end

  def recent_posts
    Post.recent
  end
end
