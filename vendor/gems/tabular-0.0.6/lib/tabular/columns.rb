module Tabular
  # The Table's header: a list of Columns.
  class Columns
    include Enumerable
    
    # +data+ -- array of header names
    # +columns_map+ -- see Table. Maps column names and type conversion.
    def initialize(data, columns_map = {})
      columns_map ||= {}
      @columns_map = normalize_columns_map(columns_map)
      @column_indexes = {}
      @columns_by_key = {}
      index = 0
      @columns = nil
      @columns = data.map do |column|
        new_column = Tabular::Column.new(column, @columns_map)
        unless new_column.key.blank?
          @column_indexes[new_column.key] = index
          @columns_by_key[new_column.key] = new_column
        end
        index = index + 1
        new_column
      end
    end
    
    # Is the a Column with this key? Keys are lower-case, underscore symbols.
    # Example: :postal_code
    def has_key?(key)
      @columns.any? { |column| column.key == key }
    end
    
    # Column for +key+
    def [](key)
      @columns_by_key[key]
    end
    
    # Zero-based index of Column for +key+
    def index(key)
      @column_indexes[key]
    end
    
    # Call +block+ for each Column
    def each(&block)
      @columns.each(&block)
    end
    
    # Add a new Column with +key+
    def <<(key)
      column = Column.new(key, @columns_map)
      unless column.key.blank?
        @column_indexes[column.key] = @columns.size
        @column_indexes[@columns.size] = column
        @columns_by_key[column.key] = column
      end
      @columns << column
    end
    
    
    private 
    
    def normalize_columns_map(columns_map)
      normalized_columns_map = {}
      columns_map.each do |key, value|
        case value
        when Hash, Symbol
          normalized_columns_map[key.to_sym] = value
        else
          normalized_columns_map[key.to_sym] = value.to_sym
        end
      end
      normalized_columns_map
    end
  end
end
