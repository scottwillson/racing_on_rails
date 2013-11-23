class ArticleCategoriesController < ApplicationController
  def show
    @article_category = ArticleCategory.find(params[:id])
    @article_category.articles.delete_if { |article| !article.display? }

    top_level_article_category_id = @article_category.parent_id
    top_level_article_category_id = params[:id] if top_level_article_category_id == 0

    @article_categories = ArticleCategorywhere(:parent_id => top_level_article_category_id).order(:position)
    @article_categories.each { |article_category| article_category.articles.delete_if { |article| !article.display? }}
  end
end
