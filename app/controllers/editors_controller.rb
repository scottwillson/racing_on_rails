class EditorsController < ApplicationController
  before_filter :require_current_person
  before_filter :assign_person
  before_filter :require_same_person_or_administrator

  force_https

  def create
    @editor = Person.find(params[:editor_id])
    
    unless @person.editors.include?(@editor)
      @person.editors << @editor
    end
    
    flash[:notice] = "#{@editor.name} can now edit #{@person.name}'s account"
    
    if params[:return_to] == "admin"
      redirect_to edit_admin_person_path(@person)
    else
      redirect_to edit_person_path(@person)
    end
  end
  
  def destroy
    @editor = Person.find(params[:editor_id])
    
    if @person.editors.include?(@editor)
      @person.editors.delete @editor
    end
    
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
