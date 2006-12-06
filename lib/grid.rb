# @columns.first.name = 'place' if !@columns.empty? and @columns.first.name.blank?

class Grid
  attr_accessor :columns, :rows, :invalid_columns
  attr_reader :column_count, :padding, :delimiter, :quoted, :column_map

  # The Grid class maps columns by default -- it changes them to lowercase and replaces
  # spaces with underscores.
  # === Options ===
  # * delimiter: Cell delimiter. Defaults to tab
  # * quoted: Cells are surrounded by quotes -- remove first and last character. Default to false
  # * columns = Array of column names as Strings or Array of Columns
  # * header_row: First row is a list of column name. Header rows are parsed are deleted, so rows.first will return the _second_ row from the source text.
  #               Defaults to false
  # * column_map: Hash of column names. Replace column names from the original file with another name if the default mapping isn't enough.
  #               Example: 'birth date' => 'date_of_birth'. 
  #               All keys are forced to lowercase for case-insenstive comparions
  # * row_class: Map each row to this Class. Example: :row_class => Racer
  #
  # If both +columns+ and +header_row+ options are provided, +columns+ is used to create the columns, and the first row is deleted and ignored
  def initialize(source = '', *options)
    raise ArgumentError("'source' cannot be nil") if source.nil?
    
    options.flatten! if options
    @truncated = false
    @calculated_padding = false
    @invalid_columns = []

    if (options.nil? || options.empty?)
      options_hash = {}
    else
      options_hash = options.first
    end

    @delimiter = options_hash[:delimiter] || '\t'
    @header_row = options_hash[:header_row] || false
    @quoted = options_hash[:quoted] || false
    
    @column_map = {}
    if options_hash[:column_map]
      options_hash[:column_map].each do |key, value|
        @column_map[key.downcase] = value
      end
    end
    
    @row_class = options_hash[:row_class]
    if @row_class
      @row_class_instance = @row_class.new
    end

    if source.is_a?(String)
      source = source.split(/\n/)
    end

    if @header_row and source.is_a?(Array) and !source.empty?
      columns_array = source.delete_at(0)
    end
    
    if options_hash[:columns]
      columns_array = options_hash[:columns]
    end
    
    @columns = create_columns(columns_array)
    self.rows = source
  end

  def [](row)
    if row > rows.size
      raise(ArgumentError, "#{row} is greater then the number of rows: #{rows.size}")
    end
    rows[row]
  end
  
  def rows
    if @rows.nil?
      @rows = []
    end
    @rows
  end

  # Delimited String or Array of Strings or Arrays
  def rows=(source)
    for row in source
      row = row.split(/#{@delimiter}/) unless row.is_a?(Array)
      index = 0
      row = row.collect {|cell|
        if cell
          cell.strip!
          if quoted
            cell.gsub!(/^"/, '')
            cell.gsub!(/"$/, '')
          end

          if index >= column_count
            columns << Column.new
          end
          
          column = columns[index]
          if !column.fixed_size && (cell.size > column.size)
            column.size = cell.size
          end
        end

        index = index + 1
        cell
      }
      
      rows << Row.new(row, self)
    end
  end

  def row_count
    rows.size
  end
  
  def columns
    @columns = @columns || []
  end

  def column_count
    columns.size
  end

  def column_size(index)
    if columns[index]
      columns[index].size
    else
      0
    end
  end

  def create_columns(columns_array)
    @columns = []
    return if columns_array.nil?
    
    @columns = columns_array.collect do |column_name|
      if column_name.is_a?(Column)
        column_name
      else
        if !column_name.blank? && @column_map[column_name.downcase]
          column_name = @column_map[column_name.downcase]
        end
      
        column = Column.new(column_name.to_s.strip, column_name.to_s.strip)

        unless column.name.blank?
          field = column.name.downcase
          field = field.underscore
          field.gsub!(' ', '_')
          if @column_map[field]
            column.field = @column_map[field]
          else
            column.field = field
          end
        end
        column
      end
    end

    after_columns_created
    validate_columns
    
    for column in @columns
      unless column.description.blank?
        if !column.fixed_size && (column.description.size > column.size)
          column.size = column.description.size 
        end
      end
    end
  end
  
  # Callback for sub classes
  def after_columns_created
  end
  
  def validate_columns
    return unless @row_class_instance
    
    for column in @columns
      if column.field.nil? || !(@row_class_instance.respond_to?(column.field))
        column.field = nil
        @invalid_columns << column.name unless column.name.blank?
      end
    end
  end

  def index_for_column_name(name)
    columns.each_with_index do |column, index|
      if column.name == name
        return index
      end
    end
    ''
  end

  def inspect
    text = ""
    text << "#{columns}\n" if columns
    for row in rows
      text << row.inspect
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
    rows.each_with_index do |row, row_index|
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
    for row in rows
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
    rows.each_with_index do |row, row_index|
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
    rows.delete_if {|row|
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
      return '' if index.blank?
    end

    return '' if index >= size
    return slice(index) || ''
  end

  def to_hash
    hash = HashWithIndifferentAccess.new
    for index in 0..(size - 1)
      hash[@grid.columns[index].field] = self[index] if @grid.columns[index].field
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
