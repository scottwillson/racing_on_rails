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

  def pronoun(person, other_person)
    if person == other_person
      "me"
    else
      person.name
    end
  end
end
