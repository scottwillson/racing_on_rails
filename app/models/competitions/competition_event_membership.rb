class CompetitionEventMembership < ActiveRecord::Base
  validates_uniqueness_of :event_id, :scope => :competition_id
  
  belongs_to :competition
  belongs_to :event
end
