# frozen_string_literal: true

# Summarize account editing permissions
class AccountPermission
  attr_accessor :person, :can_edit_person, :person_can_edit

  def initialize(person, can_edit_person, person_can_edit)
    raise(ArgumentError, "person must be present") unless person

    @person = person
    @can_edit_person = can_edit_person
    @person_can_edit = person_can_edit
  end

  # "owner" can edit the AccountPermission person
  def can_edit_person?
    @can_edit_person
  end

  # AccountPermission person can edit "owner"
  def person_can_edit?
    @person_can_edit
  end

  def to_s
    "#<AccountPermission #{person.try(:id)} #{@can_edit_person} #{@person_can_edit}>"
  end

  def eql?(other)
    person.eql?(other.person)
  end

  delegate :hash, to: :person
end
