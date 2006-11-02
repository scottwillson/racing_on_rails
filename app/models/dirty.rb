module Dirty
  
  def clean
    @dirty = false
    # Return true after clean
    clean?
  end
  
  def clean?
    !dirty?
  end

  def dirty
    @dirty = true
  end

  def dirty?
    @dirty
  end
end