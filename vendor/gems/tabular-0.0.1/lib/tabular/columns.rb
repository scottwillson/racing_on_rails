module Tabular
  class Columns
    def initialize(data, columns_map = {})
      @columns_map = columns_map
      @column_indexes = {}
      @columns_by_key = {}
      index = 0
      @columns = data.map do |column|
        new_column = Tabular::Column.new(column, columns_map)
        unless new_column.key.blank?
          @column_indexes[new_column.key] = index
          @columns_by_key[new_column.key] = new_column
        end
        index = index + 1
        new_column
      end
    end
    
    def has_key?(key)
      @columns.any? { |column| column.key == key }
    end
    
    def [](key)
      @columns_by_key[key]
    end
    
    def index(key)
      @column_indexes[key]
    end
    
    def each(&block)
      @columns.each(&block)
    end
    
    def <<(key)
      column = Column.new(key, @columns_map)
      unless column.key.blank?
        @column_indexes[column.key] = @columns.size
        @column_indexes[@columns.size] = column
        @columns_by_key[column.key] = column
      end
      @columns << column
    end
  end
end
