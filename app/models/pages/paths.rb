# frozen_string_literal: true

module Pages
  module Paths
    extend ActiveSupport::Concern

    module ClassMethods
      def find_by_normalized_path!(path)
        find_by! path: normalize_path(path)
      end

      def normalize_path(path)
        normalized_path = ""

        if path
          normalized_path = path.dup
          normalized_path.gsub!(/^\/m/, "")
          normalized_path.gsub!(/^\//, "")
          normalized_path.gsub!(/.html$/, "")
          normalized_path.gsub!(/\/index$/, "")
          normalized_path.gsub!(/^index$/, "")
        end
        normalized_path
      end
    end

    # Parent +slug+ paths + +slug+
    def set_path
      # Ouch
      _ancestors = ancestors.reverse
      _ancestors.delete(parent)
      _ancestors << ::Page.find(parent_id) if parent_id

      self.path = (_ancestors << self).map(&:slug).join("/").gsub(/^\//, "")
    end
  end
end
