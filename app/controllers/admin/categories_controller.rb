# Manage Asssociation and BAR categories
class Admin::CategoriesController < Admin::AdminController
  before_filter :require_administrator
  layout "admin/application"

  # Show all Association Categories
  # === Assigns
  # * categories
  def index
    respond_to do |format|
      format.html {
        @category = Category.find_or_create_by_name(RacingAssociation.current.short_name)
        @unknowns = Category.find_all_unknowns
      }
      format.js {
        render :update do |page|
          @category = Category.find(params[:category_id], :include => :children)
          page.replace_html "category_#{@category.id}_children", :partial => "category", :collection => @category.children.sort
        end
      }
    end
  end
    
  # Add category as child
  def add_child
    category_id = params[:id]
    @category = Category.find(category_id)
    parent_id = params[:parent_id]
    if parent_id.present?
      @parent = Category.find(parent_id)
      @category.parent = @parent    
    else
      @category.parent = nil
    end
    @category.save!
    render :update do |page|
      page.remove "category_#{@category.id}_row"
      if @parent
        if @parent.name == RacingAssociation.current.short_name
          page.replace_html "association_category_root", :partial => "category", :collection => @parent.children.sort
          page.call :bindCategoryEvents
        else
          page.call :expandDisclosure, parent_id
        end
      else
        page.replace_html "unknown_category_root", :partial => "category", :collection => Category.find_all_unknowns.sort
        page.call :bindCategoryEvents
      end
    end
  end

  # Calculate MbraBar only
  def recompute_bar
    MbraBar.calculate!
    redirect_to :action => :index
  end

  # Calculate MbraTeamBar only
  def recompute_team_bar
    MbraTeamBar.calculate!
    redirect_to :action => :index
  end
end
