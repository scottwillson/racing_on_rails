# Remember if object has been modified. 
# You must manually set make the object dirty or clean
module Dirty
  
  # Mark as not dirty
  def clean
    @dirty = false
    # Return true after clean
    clean?
  end
  
  def clean?
    !dirty?
  end

  # Mark as dirty
  def dirty
    @dirty = true
  end

  def dirty?
    @dirty
  end
end