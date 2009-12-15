module Tabular
  # Associate list of cells. Each Table has a list of Rows. Access Row cells via symbols. Ex: row[:city]
  class Row
    include Enumerable
    
    # +columns+ -- array of string
    # +cell+ -- array (not neccessarily Strings)
    def initialize(columns, cells = [])
      @columns = columns
      @array = cells
      @hash = nil
    end
    
    # Cell value by symbol. E.g., row[:phone_number]
    def [](key)
      hash[key]
    end
    
    # Set cell value. Adds cell to end of Row and adds new Column if there is no Column fo +key_
    def []=(key, value)
      if @columns.has_key?(key)
        @array[@columns.index(key)] = value
      else
        @array << value
        @columns << key
      end
      hash[key] = value
    end
    
    # Call +block+ for each cell
    def each(&block)
      @array.each(&block)
    end

    # For pretty-printing cell values
    def join(sep = nil)
      @array.join(sep)
    end
    
    def to_hash
      hash.dup
    end
    
    def inspect
      hash.inspect
    end
    
    def to_s
      @array.join(", ").to_s
    end


    protected
    
    
    def hash #:nodoc:
      unless @hash
        @hash = Hash.new
        @columns.each do |column|
          index = @columns.index(column.key)
          if index
            case column.column_type
            when :boolean
              @hash[column.key] = [1, "1", true, "true"].include?(@array[index])
            when :date
              if @array[index].is_a?(Date) || @array[index].is_a?(DateTime) || @array[index].is_a?(Time)
                @hash[column.key] = @array[index]
              else
                @hash[column.key] = Date.parse(@array[index], true)
              end
            else
              @hash[column.key] = @array[index]
            end
          end
        end
      end
      @hash
    end
  end
end
