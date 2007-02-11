class Array
  require 'enumerator'
  
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
    
    [rows, row_index]
  end
end