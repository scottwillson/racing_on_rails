# frozen_string_literal: true

module Events
  module Comparison
    extend ActiveSupport::Concern

    include Comparable

    def ==(other)
      return true if equal?(other)

      return false if !other.respond_to?(:id) || !other.respond_to?(:new_record?)

      return false if new_record? || other.new_record?

      id == other.id
    end

    def eql?(other)
      return true if equal?(other)

      return false if !other.respond_to?(:id) || !other.respond_to?(:new_record?)

      return false if new_record? || other.new_record?

      id == other.id
    end

    def <=>(other)
      return -1 if other.nil? || !other

      if date
        if other.date
          return date <=> other.date
        else
          return -1
        end
      elsif other.date
        return 1
      end

      return id <=> other.id unless new_record? || other.new_record?

      0
    end
  end
end
