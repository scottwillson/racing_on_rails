module Admin
  # Manage Asssociation and BAR categories
  class CategoriesController < Admin::AdminController
    # Show all Association Categories
    # === Assigns
    # * categories
    def index
      if params[:parent_id].present?
        @category = Category.includes(:children).where(id: params[:parent_id]).first
      else
        @category = Category.find_or_create_by(name: RacingAssociation.current.short_name)
        @unknowns = Category.find_all_unknowns
      end
    end

    def edit
      @category = Category.find(params[:id])
    end

    def update
      @category = Category.find(params[:id])
      @category.update(category_params)
      # parent_id could be nil, so can't use @category.children
      if @category.parent_id
        @children = @category.parent.children
      else
        @children = Category.find_all_unknowns
      end

      respond_to do |type|
        type.js
        type.html { redirect_to edit_admin_category_path(@category) }
      end
    end

    # Calculate MbraBar only
    def recompute_bar
      MbraBar.calculate!
      redirect_to action: :index
    end

    # Calculate MbraTeamBar only
    def recompute_team_bar
      MbraTeamBar.calculate!
      redirect_to action: :index
    end


    private

    def category_params
      params_without_mobile.require(:category).permit(:parent_id, :position, :raw_name)
    end
  end
end
