module PeopleHelper
  def administrator?
    current_person && current_person.administrator?
  end

  def promoter?
    current_person && current_person.promoter?
  end
end
