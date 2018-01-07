# frozen_string_literal: true

require "set"

module Test
  module EnumerableAssertions
    # Assert two Enumerable objects contain exactly same object in any order
    def assert_same_elements(expected, actual, message = "")
      return if expected.nil? && actual.nil?
      if !expected.nil? && actual.nil?
        flunk "#{message}\n Expected #{expected} but was nil"
        elseif expected.nil? && !actual.nil?
        flunk "#{message}\n Expected nil but was #{actual}"
      end
      _expected = expected
      _expected = Set.new(_expected) unless _expected.is_a?(Set)
      _actual = actual
      _actual = Set.new(_actual) unless _actual.is_a?(Set)
      difference = _expected.difference(_actual)
      difference = _actual.difference(_expected) if difference.empty?
      unless difference.empty?
        expected_message = if expected.empty?
                             "[]"
                           else
                             expected.to_a.join(", ")
                           end
        actual_message = if actual.empty?
                           "[]"
                         else
                           actual.to_a.join(", ")
                         end
        flunk "#{message}\nExpected\n#{expected_message} but was \n#{actual_message}.\nDifference: #{difference.to_a.join(', ')}"
      end
    end

    # Assert two Enumerable objects contain exactly same object in the same order
    def assert_equal_enumerables(expected, actual, message)
      diff = expected - actual
      raise("#{message}. Expected to find #{diff.join(', ')} in #{actual.join(', ')}") unless diff.empty?

      diff = actual - expected
      raise("#{message}. Did not expect #{diff.join(', ')} in #{actual.join(', ')}") unless diff.empty?

      expected.each_with_index do |expected_member, index|
        actual_member = actual[index]
        assert_equal(expected_member, actual_member, "Expected #{expected_member} at index #{index}, but was #{actual_member}")
      end
    end
  end
end
