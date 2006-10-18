# Foreign key constraints require very specific fixture order
# fixtures :promoters, :events, :aliases_disciplines, :disciplines, :users

require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper') # the default rails helper

# ensure that the Engines testing enhancements are loaded.
require File.join(Engines.config(:root), "engines", "lib", "engines", "testing_extensions")

# Ensure that the code mixing and view loading from the application is disabled
Engines.disable_app_views_loading = true
Engines.disable_app_code_mixing = true

# set up the fixtures location
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__)  + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase
  fixtures :teams, :racers, :disciplines, :aliases, :aliases_disciplines, :categories, :promoters, :events, :standings, :races, :results, :discipline_bar_categories, :number_issuers, :race_numbers, :users
end

# Assert two Enumerable objects contain exactly same object in any order
def assert_same_elements(expected, actual, message = '')
  if expected.nil? && actual.nil?
    return
  end
  if !expected.nil? && actual.nil?
    raise "#{message}\n Expected #{expected} but was nil"
  elseif expected.nil? && !actual.nil?
    raise "#{message}\n Expected nil but was #{actual}"
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
    raise "#{message}\n Expected \n#{expected_message} but was \n#{actual_message}.\ Difference: #{difference.to_a.join(', ')}"
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
end

# Assert Arrays of Results are the same. Only considers place, Racer, and time
def assert_results(expected, actual, message = nil)
  assert_equal(expected.size, actual.size, "Size of results. #{message}")
  expected.each_with_index {|result, index|
    assert_equal((index + 1).to_s, actual[index].place.to_s, "place for #{result}. #{message}")
    assert_equal(result.racer, actual[index].racer, "racer for #{result}. #{message}")
    assert_equal(result.time, actual[index].time, "time for #{result}. #{message}")
  }
end

# TODO Add Time assert  
# Expected = date in yyyy-mm-dd format
def assert_equal_dates(expected, actual, message = nil, format = "%Y-%m-%d")
  if expected != nil && (expected.is_a?(Date) || expected.is_a?(DateTime) || expected.is_a?(Time))
    expected = expected.strftime(format)
  end
  formatted_actual = actual
  if !actual.nil? and (actual.is_a?(Date) || actual.is_a?(DateTime) || actual.is_a?(Time))
    formatted_actual = actual.strftime(format)
  end
  raise("#{message} \nExpected #{expected} \nbut was #{formatted_actual}") unless expected == formatted_actual
end
