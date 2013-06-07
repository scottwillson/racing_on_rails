# Edit categories for articles for homepage. Unrelated to Event Categories.
class Admin::ArticleCategoriesController < Admin::AdminController
  def index
    @article_categories = ArticleCategory.all( :order => "parent_id, position")
  end

  def show
    @article_category = ArticleCategory.find(params[:id])
  end

  def new
    @article_category = ArticleCategory.new
    render :edit
  end

  def edit
    @article_category = ArticleCategory.find(params[:id])
  end

  def create
    @article_category = ArticleCategory.new(params[:article_category])

    if @article_category.save
      flash[:notice] = 'ArticleCategory was successfully created.'
      redirect_to admin_article_categories_url
    else
      render :edit
    end
  end

  def update
    @article_category = ArticleCategory.find(params[:id])

    if @article_category.update_attributes(params[:article_category])
      flash[:notice] = 'ArticleCategory was successfully updated.'
      redirect_to(admin_article_categories_url)
    else
      render :edit
    end
  end

  def destroy
    @article_category = ArticleCategory.find(params[:id])
    @article_category.destroy

    redirect_to admin_article_categories_url
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = "Article Categories"
  end
end
