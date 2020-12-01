# frozen_string_literal: true

class Array
  # [a, b, c, d].each_row.do |first, second|
  #   puts("#{first}, #{second}")
  # end
  # >> "a, b"
  # >> "c, d"
  #
  # Used for races table on top of results page
  def each_row
    return [nil, nil] if empty?

    rows = []
    row_count = (size + 1) / 2

    (0..(row_count - 1)).each do |row_index|
      row = [self[row_index]]
      second_element_index = (row_count - 1) + row_index + 1
      row << self[second_element_index] if second_element_index < size
      rows << row
      yield row
    end

    rows
  end
end
