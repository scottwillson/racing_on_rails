require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class RulesTest < CalculationsTest
      def test_default_rules
        assert Calculator.default_rules[:members_only] == true, "Default rules should be a Hash that has a :members_only key"
      end
  
      def test_remove_nil_rules
        rules = { members_only: nil }
        assert Calculator.default_rules_merge(rules)[:members_only] == true, "Reject nil values in rules"
      end
    end
  end
end

