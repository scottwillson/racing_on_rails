module HomeHelper
  # Set homepage @photo_columns to 1..3 based of homepage photo size
  def photo_width_x_height(width, height)
    @photo_width = width
    @photo_height = height
    case @photo_width
    when 0..285
      @photo_columns = 1
    when 286..574
      @photo_columns = 2
    else
      @photo_columns = 3
    end
  end
end
