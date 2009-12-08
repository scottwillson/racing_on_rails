module Tabular
  class Row
    include Enumerable
    
    def initialize(columns, cells = [])
      @columns = columns
      @array = cells
    end
    
    def [](key)
      hash[key]
    end
    
    def []=(key, value)
      if @columns.has_key?(key)
        @array[@columns.index(key)] = value
      else
        @array << value
        @columns << key
      end
      hash[key] = value
    end
    
    def each(&block)
      @array.each(&block)
    end
    
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
    
    def hash
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
