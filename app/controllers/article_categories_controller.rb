class ArticleCategoriesController < ApplicationController
  def show
    @article_category = ArticleCategory.find(params[:id])
    
    # Determine what category id to use to generate sub catg tabs
    @top_level_article_category_id = @article_category.parent_id
    @top_level_article_category_id = params[:id] if @top_level_article_category_id == 0
  end
end
