# Homepage articles. Includes XML format.
class Admin::ArticlesController < Admin::AdminController
  def index
    if params[:article_category_id].nil?
      @articles = Article.all( :order => "title")
    else
      @articles = Article.all( :conditions => ["article_category_id = ?", params[:article_category_id]], :order => "title")
      params[:article_category_id] = nil
    end
  end

  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @article }
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
    @article = Article.new(params[:article])

    if @article.save
      expire_cache
      flash[:notice] = 'Article was successfully created.'
      redirect_to admin_articles_url
    else
      render :edit
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update_attributes(params[:article])
      expire_cache
      flash[:notice] = 'Article was successfully updated.'
      redirect_to admin_articles_url
    else
      render :edit
    end
  end

  def destroy
    expire_cache
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to admin_articles_url
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = "Articles"
  end
end
