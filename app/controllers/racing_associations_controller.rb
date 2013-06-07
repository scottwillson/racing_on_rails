class RacingAssociationsController < Admin::AdminController
  def edit
    @racing_association = RacingAssociation.find(params[:id])
  end

  def update
    @racing_association = RacingAssociation.find(params[:id])
    if @racing_association.update_attributes(params[:racing_association])
      flash[:notice] = "Updated #{@racing_association.name}"
      redirect_to edit_racing_association_path(@racing_association)
    else
      render :edit
    end
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = "Site"
  end
end
