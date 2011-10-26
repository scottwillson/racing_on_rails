class ArticlesController < ApplicationController
  def show
    expires_in 1.hour, :public => true
    @article = Article.find(params[:id])
  end
end