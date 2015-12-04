class MembershipsController < ApplicationController
  force_https
  before_action :require_current_person

  def show
    @person = Person.find(params[:person_id])
  end
end
