module Results
  class RowMapper
    def map(array)
      Hash[*array]
    end
  end
end
