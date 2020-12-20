# frozen_string_literal: true

module PeopleHelper
  # Is current Person an administrator?
  def administrator?
    current_person&.administrator?
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

    capture(&block) if ((attributes && (attributes.any? { |a| person[a].blank? || subject[a].blank? })) || current_person&.can_edit?(subject)) && block
  end

  def account_permission_return_to(person, current_person)
    if person.new_record?
      nil
    elsif current_person.administrator?
      edit_admin_person_path person
    else
      edit_person_path person
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

  def abbreviate_category(category)
    case category
    when /Begin/i
      "Beg"
    when /Clyde/i
      "Clyd"
    else
      category
    end
  end
end
