# Old versions of Person. Only goes back since we started using Vestal Versions.
class VersionsController < ApplicationController
  before_filter :require_person
  before_filter :assign_person
  before_filter :require_same_person_or_administrator_or_editor

  ssl_required :index

  def assign_person
    @person = Person.find(params[:person_id])
  end
end
