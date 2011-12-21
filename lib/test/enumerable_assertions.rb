require "set"

module Test
  module EnumerableAssertions
    # Assert two Enumerable objects contain exactly same object in any order
    def assert_same_elements(expected, actual, message = '')
      if expected.nil? && actual.nil?
        return
      end
      if !expected.nil? && actual.nil?
        flunk "#{message}\n Expected #{expected} but was nil"
      elseif expected.nil? && !actual.nil?
        flunk "#{message}\n Expected nil but was #{actual}"
      end
      _expected = expected
      if !_expected.is_a?(Set)
        _expected = Set.new(_expected)
      end
      _actual = actual
      if !_actual.is_a?(Set)
        _actual = Set.new(_actual)
      end
      difference = _expected.difference(_actual)
      if difference.empty?
        difference = _actual.difference(_expected)
      end
      if !difference.empty?
        if expected.empty?
          expected_message = "[]"
        else
          expected_message = expected.to_a.join(', ')
        end
        if actual.empty?
          actual_message = "[]"
        else
          actual_message = actual.to_a.join(', ')
        end
        flunk "#{message}\nExpected\n#{expected_message} but was \n#{actual_message}.\nDifference: #{difference.to_a.join(', ')}"
      end
    end
  
    # Assert two Enumerable objects contain exactly same object in the same order
    def assert_equal_enumerables(expected, actual, message)
      diff = expected - actual
      unless diff.empty?
        fail("#{message}. Expected to find #{diff.join(', ')} in #{actual.join(', ')}")
      end
  
      diff = actual - expected
      unless diff.empty?
        fail("#{message}. Did not expect #{diff.join(', ')} in #{actual.join(', ')}")
      end
    
      expected.each_with_index do |expected_member, index|
        actual_member = actual[index]
        assert_equal(expected_member, actual_member, "Expected #{expected_member} at index #{index}, but was #{actual_member}")
      end
    end
  end
end
