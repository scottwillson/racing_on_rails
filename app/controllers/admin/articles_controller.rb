# frozen_string_literal: true

module Admin
  # Homepage articles. Includes XML format.
  class ArticlesController < Admin::AdminController
    def index
      if params[:article_category_id].nil?
        @articles = Article.order(:title)
      else
        @articles = Article.where(article_category_id: params[:article_category_id]).order("title")
        params[:article_category_id] = nil
      end
    end

    def show
      @article = Article.find(params[:id])

      respond_to do |format|
        format.html
        format.xml { render xml: @article }
      end
    end

    def new
      @article = Article.new
      @article_category = ArticleCategory.first
      render :edit
    end

    def edit
      @article = Article.find(params[:id])
      @article_category = ArticleCategory.find(@article.article_category_id)
    end

    def create
      @article = Article.new(article_params)

      if @article.save
        expire_cache
        flash[:notice] = "Article was successfully created."
        redirect_to admin_articles_url
      else
        render :edit
      end
    end

    def update
      @article = Article.find(params[:id])

      if @article.update(article_params)
        expire_cache
        flash[:notice] = "Article was successfully updated."
        redirect_to admin_articles_url
      else
        render :edit
      end
    end

    def destroy
      @article = Article.find(params[:id])
      @article.destroy
      expire_cache

      redirect_to admin_articles_url
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "Articles"
    end

    private

    def article_params
      params.require(:article).permit(:article_category_id, :body, :display, :position, :title)
    end
  end
end
