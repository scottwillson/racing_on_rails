# Hash that keeps a count for each key
class HashBag < Hash

  def initialize
    @counts = {}
    super
  end

  def []=(key, value)
    count = count(key)
    count = count + 1
    @counts[key] = count
    super
  end

  def count(key)
    count = @counts[key]

    if count != nil
      count    
    else
      0
    end
  end
end
