# frozen_string_literal: true

require_relative "default_result_renderer"

module Results
  module Renderers
    class RejectionReasonRenderer < Results::Renderers::DefaultResultRenderer
      def self.render(_column, row)
        result = row.source
        I18n.t result.rejection_reason, category: result.category
      end
    end
  end
end
