# TODO Should this be in database as full-fledged ActiveRecord?
# bar_point_schedule should be stored in the database with the BAR?
class RacingAssociation

  attr_accessor :name, :gender_specific_numbers, :rental_numbers, :short_name, :show_license, :state
  attr_accessor :show_only_association_sanctioned_races_on_calendar, :bar_point_schedule, :overall_bar
  
  def initialize
    @show_license = true
    @bar_point_schedule = [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1]
    @overall_bar = true
  end

  def gender_specific_numbers?
    @gender_specific_numbers
  end
end
