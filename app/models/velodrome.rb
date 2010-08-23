# Member velodromes. Only used by ATRA, and not sure they use it any more.
class Velodrome < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
end
