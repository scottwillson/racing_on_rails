require_relative "../../test_case"
require_relative "../../../../app/helpers/results/mapper"

# :stopdoc:
module Results
  class MapperTest < Ruby::TestCase
    def test_numeric_custom_columns
      mapper = Results::Mapper.new([], [ 20130501 ])
      result = mock("result", custom_attribute: 3)
      mapper.map result
    end
  end
end
