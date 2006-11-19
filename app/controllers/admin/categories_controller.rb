# Manage Asssociation and BAR categories
class Admin::CategoriesController < Admin::RecordEditor

  include ApplicationHelper

  model :category
  edits :category

  # Show all Association Categories
  # === Assigns
  # * categories
  def index
    @categories = Category.find_all_by_scheme(ASSOCIATION.short_name)
  end
  
  # Edit Category name inline
  # === Assigns
  # * category
  def edit_name
    @category = Category.find(@params[:id])
    render(:partial => 'edit')
  end
  
  # Edit Category BAR Category inline
  def edit_bar_category
    category = Category.find(@params[:id])
    bar_categories = bar_category_choices()
    render(:partial => 'edit_bar_category', :locals => {:category => category, :bar_categories => bar_categories})
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
  
  # Update Category BAR category inline
  def update_bar_category
    begin
      category_id = params[:category][:id]
      @category = Category.find(category_id)
      bar_category_id = params[:bar_category_id]
      if bar_category_id.blank?
        bar_category = nil
      else
        bar_category = Category.find(params[:bar_category_id])
      end
      @category.bar_category = bar_category
      
      saved = @category.save
      if saved
        render(:partial => 'bar_category', :locals => {:category => @category})
      else
        @bar_categories = bar_category_choices()
        render(:partial => 'edit_bar_category', :locals => {:bar_categories => @bar_categories})
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{e}\n#{stack_trace}")
      @category.errors.add('bar_category', e)
      @bar_categories = bar_category_choices()
      render(:partial => 'edit_bar_category', :locals => {:bar_categories => @bar_categories})
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
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{category.name}"
      render :update do |page|
        page.replace_html("message_#{category.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end

  # Re-order Category via drag and drop
  def insert_at
    category_id = @params[:id].gsub('category_', '')
    @category = Category.find(category_id)
    target_id = params[:target_id]
    @target = Category.find(target_id)
    target_position = @target.position
    @target.increment_position
    @category.insert_at(target_position)
    begin
      render :update do |page|
        page.remove("category_#{category_id}_row")
        page.insert_html(:before, "category_#{target_id}_row", render(:partial => 'category', :locals => {:category => @category }))
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{error}\n#{stack_trace}")
      message = "Could not insert category"
      render :update do |page|
        page.replace_html("message_category_name_#{target_id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  # Blank Category + all BAR Categories. Could handle this on the front-end probably
  def bar_category_choices
    [Category::NONE] + Category.find_all_by_scheme('BAR')
  end
end