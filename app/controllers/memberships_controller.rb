# frozen_string_literal: true

class MembershipsController < ApplicationController
  before_action :require_current_person

  def show
    @person = Person.find(params[:person_id])
  end
end
