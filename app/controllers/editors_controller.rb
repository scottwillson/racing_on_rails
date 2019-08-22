# frozen_string_literal: true

class EditorsController < ApplicationController
  before_action :require_current_person
  before_action :assign_person
  before_action :require_same_person_or_administrator

  def create
    @editor = Person.find(params[:editor_id])

    @person.editors << @editor unless @person.editors.include?(@editor)

    flash[:notice] = "#{@editor.name} can now edit #{@person.name}'s account"

    if params[:return_to] == "admin"
      redirect_to edit_admin_person_path(@person)
    else
      redirect_to edit_person_path(@person)
    end
  end

  def destroy
    @editor = Person.find(params[:editor_id])

    @person.editors.delete @editor if @person.editors.include?(@editor)

    flash[:notice] = "#{@editor.name} can no longer edit #{@person.name}'s account"

    if params[:return_to] == "admin"
      redirect_to edit_admin_person_path(@person)
    else
      redirect_to edit_person_path(@person)
    end
  end

  private

  def assign_person
    @person = Person.find(params[:id])
  end
end
