# frozen_string_literal: true

# Homepage
class HomeController < ApplicationController
  before_action :require_administrator, except: %i[index show]

  # Show homepage
  # === Assigns
  # * upcoming_events
  # * recent_results: Events with Results within last two weeks
  def index
    @page_title = RacingAssociation.current.name

    assign_home
    @photo = @home.photo

    @events_with_recent_results = Event.with_recent_results(@home.weeks_of_recent_results.weeks.ago)
    @most_recent_event_with_recent_result = Event.most_recent_with_recent_result(@home.weeks_of_recent_results.weeks.ago)

    @news_category = ArticleCategory.where(name: "news")
    @recent_news = Article.recent_news(@home.weeks_of_upcoming_events.weeks.ago, @news_category) if @news_category

    respond_to do |format|
      format.html { render_page }
    end
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

  def show
    redirect_to(root_path)
  end

  private

  def assign_home
    @home = Home.current
  end

  def home_params
    params_without_mobile.require(:home).permit(:photo_id, :weeks_of_recent_results, :weeks_of_upcoming_events)
  end
end
