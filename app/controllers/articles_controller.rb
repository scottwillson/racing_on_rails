class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    render :layout => !request.xhr?
  end
end