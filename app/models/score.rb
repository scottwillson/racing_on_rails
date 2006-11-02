class Score < ActiveRecord::Base
  belongs_to :source_result, :class_name => 'Result', :foreign_key => 'source_result_id'
  belongs_to :competition_result, :class_name => 'Result', :foreign_key => 'competition_result_id'
  
  validates_presence_of :source_result, :competition_result, :points
  validates_numericality_of :points
  
  def <=>(other)
    other.points <=> points
  end

  def to_s
    "<Score #{id} #{source_result_id} #{competition_result_id} #{points}>"
  end
end
