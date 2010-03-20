module PeopleHelper
  def administrator?
    current_person.try :administrator?
  end

  def promoter?
    current_person.try :promoter?
  end

  def official?
    current_person.try :official?
  end
end
