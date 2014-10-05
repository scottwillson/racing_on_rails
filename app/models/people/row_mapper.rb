module People
  class RowMapper
    def map(source_row)
      puts source_row
      source_row
      # row = Hash.new
      # source_row.each do |value|
      #   if prototype.respond_to?(attr)
      #     row[attr] = value
      #   elsif COLUMN_MAP[attr]
      #     row[COLUMN_MAP[attr]] = value
      #   end
      # end
      # row
    end

    def prototype
      @prototype ||= Person.new
    end
  end
end
