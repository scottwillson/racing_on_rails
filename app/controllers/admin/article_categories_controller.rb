class Admin::ArticleCategoriesController < ApplicationController

  layout 'admin/application'
  before_filter :require_administrator

  # GET /article_categories
  # GET /article_categories.xml
  def index
    @article_categories = ArticleCategory.find(:all, :order => "parent_id, position")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @article_categories }
    end
  end

  # GET /article_categories/1
  # GET /article_categories/1.xml
  def show
    @article_category = ArticleCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article_category }
    end
  end

  # GET /article_categories/new
  # GET /article_categories/new.xml
  def new
    @article_category = ArticleCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article_category }
    end
  end

  # GET /article_categories/1/edit
  def edit
    @article_category = ArticleCategory.find(params[:id])
  end

  # POST /article_categories
  # POST /article_categories.xml
  def create
    @article_category = ArticleCategory.new(params[:article_category])

    respond_to do |format|
      if @article_category.save
        flash[:notice] = 'ArticleCategory was successfully created.'
        format.html { redirect_to(admin_article_categories_url) }
        format.xml  { render :xml => @article_category, :status => :created, :location => @article_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /article_categories/1
  # PUT /article_categories/1.xml
  def update
    @article_category = ArticleCategory.find(params[:id])

    respond_to do |format|
      if @article_category.update_attributes(params[:article_category])
        flash[:notice] = 'ArticleCategory was successfully updated.'
        format.html { redirect_to(admin_article_categories_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /article_categories/1
  # DELETE /article_categories/1.xml
  def destroy
    @article_category = ArticleCategory.find(params[:id])
    @article_category.destroy

    respond_to do |format|
      format.html { redirect_to(admin_article_categories_url) }
      format.xml  { head :ok }
    end
  end
end
