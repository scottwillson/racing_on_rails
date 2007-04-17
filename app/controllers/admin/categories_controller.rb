# Manage Asssociation and BAR categories
class Admin::CategoriesController < Admin::RecordEditor

  include ApplicationHelper

  model :category
  edits :category

  # Show all Association Categories
  # === Assigns
  # * categories
  def index
    if params[:id]
      @category = Category.find(params[:id])
    else
      @category = Category.find_or_create_by_name(ASSOCIATION.short_name)
    end
    @unknowns = Category.find_all_unknowns
  end
  
  def create
    begin
      new_name = params[:name]
      @association_category = Category.find_by_name(ASSOCIATION.short_name)
      @category = @association_category.children.create(:name => new_name)
      
      saved = @category.save
      if saved
        flash[:info] = "Created #{new_name}"
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      flash[:error] = e
    end
    render :update do |page|
      page.redirect_to(:action => :index)
    end
  end

  # Edit Category name inline
  # === Assigns
  # * category
  def edit_name
    @category = Category.find(@params[:id])
    render(:partial => 'edit')
  end
  
  # Update Category name inline
  def update
    begin
      new_name = params[:name]
      category_id = @params[:id]
      @category = Category.find(@params[:id])
      original_name = @category.name
      @category.name = new_name
      existing_category = Category.find_by_name(new_name)
      
      saved = @category.save
      if saved
        render(:partial => '/admin/attribute', :locals => {:record => @category, :name => 'name'})
      else
        render(:partial => 'edit')
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{e}\n#{stack_trace}")
      @category.name = original_name
      @category.errors.add('name', e)
      render(:partial => 'edit')
    end
  end
  
  # Cancel inline Category edit
  def cancel
    if @params[:id]
      category = Category.find(@params[:id])
      attribute(category, 'name')
    else
      render(:text => '<tr><td colspan=5></td></tr>')
    end
  end

  # Destroy Category
  def destroy
    category = Category.find(params[:id])
    begin
      category.destroy
      render :update do |page|
        page.visual_effect(:puff, "category_#{category.id}_row", :duration => 2)
        page.replace_html(
          'message', 
          "#{image_tag('icons/confirmed.gif', :height => 11, :width => 11, :id => 'confirmed') } Deleted #{category.name}"
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{category.name}: #{error}"
      render :update do |page|
        page.replace_html(
          'message', 
          "#{image_tag('icons/warn.gif', :height => 11, :width => 11, :id => 'warn') } #{message}"
        )
      end
    end
  end

  # Add category as child
  def add_child
    category_id = @params[:id].gsub('category_', '')
    @category = Category.find(category_id)
    parent_id = params[:parent_id]
    if parent_id
      @parent = Category.find(parent_id)
      @category.parent = @parent    
    else
      @category.parent = nil
    end
    begin
      @category.save!
      render :update do |page|
        page.redirect_to(:action => :index)
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{error}\n#{stack_trace}")
      message = "Could not insert category"
      render :update do |page|
        page.replace_html("message_category_name_#{parent_id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
end