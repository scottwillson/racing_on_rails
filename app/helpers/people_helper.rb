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

  def editor_for?(person, *attributes, &block)
    subject = case person
    when Person
      person
    else
      person.try(:person)
    end
      
    if (attributes && (attributes.any? { |a| person[a].blank? || subject[a].blank? })) || current_person.can_edit?(subject)
      if block
        concat(capture(&block))
      else
        true
      end
    else
      false
    end
  end

  def pronoun(person, other_person)
    if person == other_person
      "me"
    else
      person.name
    end
  end
end
