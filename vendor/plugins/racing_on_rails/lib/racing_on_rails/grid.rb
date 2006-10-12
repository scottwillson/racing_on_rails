require "logger"

class Grid
  attr_accessor :columns, :rows
  attr_reader :column_count, :padding

  # column_names = column names as Array of Strings
  def initialize(text = nil, columns = [])
    @truncated = false
    @calculated_padding = false
    @rows = []
    columns = columns || []
    @columns = columns.collect do |column|
      if column.is_a? String
        Column.new(column.to_s.strip, column.to_s.strip)
      else
        column
      end
    end
    after_columns_created
    populate(text)
  end

  # Hook for subclasses
  def after_columns_created
  end

  def populate(rows)
    return if rows.nil?
    rows = rows.split(/\n/) unless rows.is_a?(Array)
    for row in rows
      row = row.split(/\t/) unless row.is_a?(Array)
      row = row.collect {|cell|
        if cell != nil
          cell.strip!
          cell
        end
      }
      @rows << Row.new(row, self)
    end
    calculate_columns
  end

  def [](row)
    if row > @rows.size
      raise(ArgumentError, "#{row} is greater then the number of rows: #{@rows.size}")
    end
    @rows[row]
  end

  def rows=(rows)
    @rows = rows
    calculate_columns
  end

  def row_count
    @rows.size
  end

  def column_count
    @columns.size
  end

  def column_size(index)
    if @columns[index]
      @columns[index].size
    else
      0
    end
  end

  def calculate_columns
    for column in @columns
      unless column.description.blank?
        if column.description.size > column.size
          column.size = column.description.size 
        end
      end
    end
    for row in @rows
      while row.size > column_count
        @columns << Column.new
      end
      for column_index in (0..row.size - 1)
        cell = row[column_index]
        if cell.size > @columns[column_index].size
          @columns[column_index].size = cell.size
        end
      end
    end
  end

  def index_for_column_name(name)
    @columns.each_with_index do |column, index|
      if column.name == name
        return index
      end
    end
    ''
  end

  def inspect
    text = ""
    text = text + "#{@columns}\n" if @columns
    for row in @rows
      text = text + row.inspect
    end
    text
  end

  def to_s(include_columns = true)
    unless truncated?
  	  truncate
	  end
	  unless calculated_padding?
	    calculate_padding
    end
  
    text = ""
    if include_columns and @columns and !@columns.empty? and !@columns.to_s.blank?
      descriptions = @columns.collect do |column|
        column.description
      end
      text = text + header_to_s(descriptions)
    end
    @rows.each_with_index do |row, row_index|
      text = text + row_to_s(row, row_index)
    end
    text
  end

  def header_to_s(row)
    text = ''
    for index in 0..(column_count - 1)
      cell = row[index] || ''
      padding = column_size(index) - cell.size
      if padding > 0
        if @columns[index].justification == Column::LEFT
          cell = cell + (" " * padding)
        else
          cell = (" " * padding) + cell
        end
      end
      if padding < 0
        cell = truncate_obra(cell, column_size(index))
      end
      text = text + cell
      unless index + 1 == row.size
        text = text + "   "
      end
    end
    text + "\n"
  end

  def row_to_s(row, row_index)
    text = ''
    for index in 0..(column_count - 1)
      cell = row[index] || ''
      if @columns[index].justification == Column::LEFT
        cell = cell + (" " * @padding[row_index][index])
      else
        cell = (" "  * @padding[row_index][index]) + cell
      end
      text = text + cell
      unless index + 1 == row.size
        text = text + "   "
      end
    end
    text + "\n"
  end

  def truncate
    @truncated = true
    for row in @rows
      for index in 0..(column_count - 1)
        cell = row[index] || ''
        if cell.size > column_size(index)
          row[index] = truncate_obra(cell, column_size(index))
        end
      end
    end
  end

  def calculate_padding
    @calculated_padding = true
    @padding = []
    @rows.each_with_index do |row, row_index|
      row_padding = []
      for index in 0..(column_count - 1)
        cell = row[index] || ''
        if cell.size <= column_size(index)
          padding = column_size(index) - cell.size
          row_padding << padding
        else
          row_padding << 0
        end
      end
      @padding << row_padding
    end
  end

  def truncated?
    @truncated
  end

  def calculated_padding?
    @calculated_padding
  end

  # TODO Just redefine helper method
  def truncate_obra(text, length = 30, truncate_string = "...")
    if text.nil? then return end

    if $KCODE == "NONE"
      text.length > length ? text[0..(length - 4)] + truncate_string : text
    else
      chars = text.split(//)
      chars.length > length ? chars[0..(length - 4)].join + truncate_string : text
    end
  end

  def delete_blank_rows
    @rows.delete_if {|row|
      row.blank?
    }
  end
end


class Row < Array
  def initialize(cells, grid)
    super(cells)
    @grid = grid
  end

 # second_arg for superclass methods
  def [](index, second_arg = -1)
    return super if second_arg != -1
    if index.is_a?(String)
      index = @grid.index_for_column_name(index)
      if index.blank?
        return ""
      end
    end

    if index >= size
      return ""
    end
    cell = slice(index)
    if cell == nil
      return ""
    end
    cell
  end

  def to_hash
    hash = HashWithIndifferentAccess.new
    for index in 0..(size - 1)
      hash[@grid.columns[index].name] = self[index] if @grid.columns[index].field
    end
    hash
  end

  def blank?
    self.each do |cell|
      return false unless cell.blank?
    end
    true
  end
end
