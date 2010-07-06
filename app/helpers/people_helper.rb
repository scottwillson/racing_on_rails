module PeopleHelper
  # Is current Person an administrator?
  def administrator?
    current_person.try :administrator?
  end

  # Is current Person a promoter?
  def promoter?
    current_person.try :promoter?
  end

  # Is current Person an official?
  def official?
    current_person.try :official?
  end

  # Can current_person edit +person+?
  def editor_for?(person, *attributes, &block)
    subject = case person
    when Person
      person
    else
      person.try :person
    end
      
    if (attributes && (attributes.any? { |a| person[a].blank? || subject[a].blank? })) || current_person.can_edit?(subject)
      if block
        concat capture(&block)
      else
        true
      end
    else
      false
    end
  end

  # 'me' or +person+ name
  def pronoun(person, other_person)
    if person == other_person
      "me"
    else
      person.name
    end
  end
end
