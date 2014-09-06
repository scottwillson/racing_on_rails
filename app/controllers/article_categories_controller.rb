class ArticleCategoriesController < ApplicationController
  def show
    @article_category = ArticleCategory.where(id: params[:id]).first

    if @article_category.nil?
      # No flash because homepages are page cached
      return redirect_to(home_path)
    end

    top_level_article_category_id = @article_category.parent_id
    top_level_article_category_id = params[:id] if top_level_article_category_id == 0

    @article_categories = ArticleCategory.where(parent_id: top_level_article_category_id).order(:position)
  end
end
