module Admin
  # Manage Asssociation and BAR categories
  class CategoriesController < Admin::AdminController
    # Show all Association Categories
    # === Assigns
    # * categories
    def index
      if params[:parent_id].present?
        @category = Category.find(params[:parent_id], :include => :children)
      else
        @category = Category.find_or_create_by_name(RacingAssociation.current.short_name)
        @unknowns = Category.find_all_unknowns
      end
    end
    
    def update
      @category = Category.find(params[:id])
      @category.update_attributes(params[:category])
      # parent_id could be nil, so can't use @category.children
      if @category.parent_id
        @children = @category.parent.children
      else
        @children = Category.find_all_unknowns
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
end
