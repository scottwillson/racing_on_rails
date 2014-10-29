module Grid
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

    # Concatenates duplicate keys into one value separated by a line return.
    # Example:
    # name | street    | street
    # Eddy | 10 Huy St | Apt #410
    #
    # name: 'Eddy'
    # steet: '10 Huy St
    #            Apt #410'
    def to_hash
      hash = HashWithIndifferentAccess.new
      for index in 0..(size - 1)
        column = @grid.columns[index]
        field = column.field
        if field

          # Existing value logic is too messy ...
          value = self[index]
          if field == :notes and !value.blank? and value[/notes/].nil? and value[/Notes/].nil? and column.description[/notes/].nil? and column.description[/Notes/].nil?
            value = "#{column.description}: #{value}"
          end

          existing_value = hash[field]
          value = nil if value == $INPUT_RECORD_SEPARATOR
          if existing_value.blank?
            if value.blank?
              hash.delete(field)
            else
              hash[field] = value
            end
          else
            unless value.blank?
              hash[field] = "#{existing_value}#{$INPUT_RECORD_SEPARATOR}#{value}"
            end
          end

        end
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
end
