class MembershipsController < ApplicationController
  before_filter :require_person
  
  def show
    @person = Person.find(params[:person_id])
  end
end
