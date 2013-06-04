module RacingOnRails
  module Tabular
    class Mapper
      def initialize(columns, custom_columns = [], columns_after_custom_columns = [])
        @columns = columns
        @custom_columns = custom_columns
        @columns_after_custom_columns = columns_after_custom_columns
      end
      
      def map(result)
        hash = {}

        @columns.each do |name|
          hash[name] = result[name]
        end

        @custom_columns.each do |name|
          hash[name] = result.send(name)
        end

        @columns_after_custom_columns.each do |name|
          hash[name] = result[name]
        end
        hash
      end
    end
  end
end
