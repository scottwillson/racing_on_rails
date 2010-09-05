class RacingAssociationsController < ApplicationController
  before_filter :require_administrator
  layout "admin/application"

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
end
