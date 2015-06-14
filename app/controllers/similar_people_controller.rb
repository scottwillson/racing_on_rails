class SimilarPeopleController < Admin::AdminController
  def index
    @people = SimilarPerson.all
  end
end
