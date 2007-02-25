# TODO Should this be in database as full-fledged ActiveRecord?
class RacingAssociation

  attr_accessor :name, :gender_specific_numbers, :rental_numbers, :short_name, :state

  def gender_specific_numbers?
    @gender_specific_numbers
  end
end
