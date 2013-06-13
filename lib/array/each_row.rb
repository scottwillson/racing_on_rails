class Array
  require 'enumerator'
  
  # [a, b, c, d].each_row.do |first, second|
  #   puts("#{first}, #{second}")
  # end
  # >> "a, b"
  # >> "c, d"
  #
  # Used for races table on top of results page
  def each_row
    return [ nil, nil ] if empty?
    rows = []
    row_count = (size + 1) / 2
    
    for row_index in 0..(row_count - 1)
      row = [self[row_index]]
      second_element_index = (row_count - 1) + row_index + 1
      if second_element_index < size
        row << self[second_element_index]
      end
      rows << row
      yield row
    end
    
    rows
  end
end
