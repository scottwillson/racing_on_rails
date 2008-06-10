module HomeHelper
  def photo_width_x_height(width, height)
    @photo_width = width
    @photo_height = height    
    @wide_photo = (@photo_width > 285)
  end
end
