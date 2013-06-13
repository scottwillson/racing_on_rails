class Array
  require 'enumerator'
  
  # [a, b, c, d].each_row_with_index.do |row, index|
  #   puts("#{row}, #{index}")
  # end
  # >> [ a, b ], 0
  # >> [ c, d ], 1
  #
  # Used for races table on top of results page. May be a Rails method for this, but doesn't include index, I think.
  # Then again, I don't think we use index any more, either.
  def each_row_with_index
    return [[], 0] if empty?
    rows = []
    row_count = (size + 1) / 2
    
    for row_index in 0..(row_count - 1)
      row = [self[row_index]]
      second_element_index = (row_count - 1) + row_index + 1
      if second_element_index < size
        row << self[second_element_index]
      end
      rows << row
      yield row, row_index
    end
    
    [ rows, row_index ]
  end
end
