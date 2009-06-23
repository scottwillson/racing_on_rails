class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    
    # Determine what category id to use to generate sub catg tabs
    @top_level_article_category_id = @article.article_category.parent_id
    @top_level_article_category_id = @article.article_category_id if @top_level_article_category_id == 0
  end
end