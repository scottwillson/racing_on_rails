# Used in Hash of results to sort out duplicate results for same race
class ResultKey
  
  include Comparable
  
  attr_reader :race_id, :racer_id

  def initialize(result)
    @race_id = result.race_id
    @racer_id = result.racer_id
  end
  
  def <=>(other)
    racer_diff = (@racer_id <=> other.racer_id)
    if racer_diff != 0
      racer_diff
    else
      @race_id <=> other.race_id
    end
  end
  
  def hash
    result = 13
    if @racer_id
      result = result + @racer_id * 37     
    end
    # Really should always have race_id ...
    if @race_id
      result = result + @race_id * 37
    end
    result
  end
  
  def eql?(other)
    self == other
  end
  
  def to_s
    "#<ResultKey #{@race_id} #{@racer_id}>"
  end
end
