module RacingOnRails
  module Tabular
    class Mapper
      def initialize(columns, custom_columns = [], columns_after_custom_columns = [])
        @columns = columns
        # Race should have symbolized columns on save but doesn't (or hasn't) always
        @custom_columns = symbolize(custom_columns)
        @columns_after_custom_columns = columns_after_custom_columns
      end

      def map(result)
        hash = {}

        @columns.each do |name|
          hash[name] = result[name]
        end

        @custom_columns.each do |name|
          hash[name] = result.custom_attribute(name)
        end

        @columns_after_custom_columns.each do |name|
          hash[name] = result[name]
        end

        hash
      end

      private

      def symbolize(custom_columns)
        custom_columns.map do |column|
          column.to_s.to_sym
        end
      end
    end
  end
end
