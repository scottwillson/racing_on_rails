# frozen_string_literal: true

module HomeHelper
  # Set homepage @photo_columns to 1..3 based of homepage photo size
  def photo_width_x_height(width, height)
    @photo_width = width
    @photo_height = height
    @photo_columns = case @photo_width
                     when 0..285
                       1
                     when 286..574
                       2
                     else
                       3
                     end
  end
end
