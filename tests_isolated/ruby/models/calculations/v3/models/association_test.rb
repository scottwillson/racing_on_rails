# frozen_string_literal: true

require_relative "../../v3"
require_relative "./equality_assertion"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class AssociationTest < Ruby::TestCase
        include EqualityAssertion

        def test_initialize
          Association.new(id: 0)
        end

        def test_equality
          a = Association.new(id: 0)
          b = Association.new(id: 0)
          c = Association.new(id: 0)
          d = Association.new(id: 1)

          assert_equality a, b, c, d
        end
      end
    end
  end
end
