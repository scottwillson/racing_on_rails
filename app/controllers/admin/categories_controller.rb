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
      @category.assign_attributes category_params

      if @category.name_changed?
        existing_category = Category.where(name: @category.name).where.not(id: @category.id).first
        if existing_category
          @category.replace_with existing_category
          @category = existing_category
        end
      end

      respond_to do |type|
        type.js do
          @category.save!

          # parent_id could be nil, so can't use @category.children
          if @category.parent_id
            @children = @category.parent.children
          else
            @children = Category.find_all_unknowns
          end
        end

        type.html do
          if @category.save
            redirect_to edit_admin_category_path(@category)
          else
            render :edit
          end
        end
      end
    end

    # Calculate MbraBar only
    def recompute_bar
      Competitions::MbraBar.calculate!
      redirect_to action: :index
    end

    # Calculate MbraTeamBar only
    def recompute_team_bar
      Competitions::MbraTeamBar.calculate!
      redirect_to action: :index
    end

    private

    def category_params
      params_without_mobile.require(:category).permit(:parent_id, :position, :raw_name)
    end
  end
end
