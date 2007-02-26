# TODO Should this be in database as full-fledged ActiveRecord?
class RacingAssociation

  attr_accessor :name, :gender_specific_numbers, :rental_numbers, :short_name, :show_license, :state
  attr_accessor :show_only_association_sanctioned_races_on_calendar
  
  def initialize
    @show_license = true
  end

  def gender_specific_numbers?
    @gender_specific_numbers
  end
end
