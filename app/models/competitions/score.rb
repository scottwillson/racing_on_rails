# Tie a Competition Result to it's source Result from a SingleDayEvent, and holds the points earned for the Competition
#
# Example: John Walrod places 3rd in the Mudslinger Singlespeed race. This earns him points for both the Singlespeed BAR
# and the Ironman:
#
# Singlespeed BAR Score
# * points: 22
# * source_result: 3rd, Mudslinger
# * competition_result: 18th Singlespeed BAR
#
# Ironman Score
# * points: 1
# * source_result: 3rd, Mudslinger
# * competition_result: 200th Ironman
class Score < ActiveRecord::Base
  belongs_to :source_result, :class_name => 'Result', :foreign_key => 'source_result_id'
  belongs_to :competition_result, :class_name => 'Result', :foreign_key => 'competition_result_id'
  
  validates_presence_of :source_result, :competition_result, :points
  validates_numericality_of :points
  
  def discipline
    self.competition_result.race.discipline
  end
  
  # Compare by points
  def <=>(other)
    other.points <=> points
  end

  def to_s
    "#<Score #{id} #{source_result_id} #{competition_result_id} #{points}>"
  end
end
