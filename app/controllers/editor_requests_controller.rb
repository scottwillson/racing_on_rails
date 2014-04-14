class EditorRequestsController < ApplicationController
  before_filter :assign_person, except: :show
  before_filter :require_current_person, except: :show

  force_https

  def create
    @editor = Person.find(params[:editor_id])
    unless @editor.administrator? || (@editor && current_person == @editor)
      return redirect_to(unauthorized_path)
    end

    if @person.editors.include?(@editor)
      if @editor == current_person
        flash[:notice] = "You can already access #{@person.name}'s account"
      else
        flash[:notice] = "#{@editor.name} can already access #{@person.name}'s account"
      end
    else
      if @person.email.present?
        @person.editor_requests.create!(editor: @editor)
        flash[:notice] = "Emailed account access request to #{@person.name}'s account"
      else
        flash[:warn] = "Can't send access request because #{@person.name} doesn't have an email address on their account. Please ask them to login to their account and grant you access directly."
      end
    end

    if params[:return_to].present?
      redirect_to only_path: true, path: params[:return_to]
    else
      redirect_to edit_person_path(@editor)
    end
  end

  def show
    @editor_request = EditorRequest.find_by_token!(params[:id])
    @editor_request.grant!
  end
end
