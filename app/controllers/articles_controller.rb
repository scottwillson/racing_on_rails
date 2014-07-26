class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    fresh_when @article, public: true
    render layout: !request.xhr?
  end
end
