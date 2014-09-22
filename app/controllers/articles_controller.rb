class ArticlesController < ApplicationController
  def show
    @article = Article.where(id: params[:id]).first

    if @article.nil?
      # No flash because homepages are page cached
      return redirect_to(home_path)
    end

    render layout: !request.xhr?
  end
end
