require_relative "../../../test_case"
require_relative "../../../../../app/helpers/results/tabular/mapper"

# :stopdoc:
module Results
  module Tabular
    class MapperTest < Ruby::TestCase
      def test_numeric_custom_columns
        mapper = Results::Tabular::Mapper.new([], [ 20130501 ])
        result = mock("result", custom_attribute: 3)
        mapper.map result
      end
    end
  end
end
