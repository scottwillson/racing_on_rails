ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require "action_view/test_case"

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  def teardown
    # Discipline class may have loaded earlier with no aliases in database
    Discipline.reset
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
    
    expected.each_with_index do |expected_member, index|
      actual_member = actual[index]
      assert_equal(expected_member, actual_member, "Expected #{expected_member} at index #{index}, but was #{actual_member}")
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

  def assert_equal_events(expected, actual, message = 'Events not equal')
    expected_sorted = expected.sort
    actual_sorted = actual ? actual.sort : []
    unless expected_sorted == actual_sorted
      expected_formatted = expected_sorted.join("\n")
      actual_formatted = actual_sorted.join("\n")
      detailed_message = "#{message}. Expected:\n#{expected_formatted} \nbut was:\n#{actual_formatted}"
      flunk(detailed_message)
    end
  end

  # Automatically removes the "layout/" prefix.
  # Example: test for default layout: assert_layout("application")
  def assert_layout(expected)
    if expected
      assert_equal("layouts/#{expected}", @response.layout, "layout")
    else
      assert_nil(@response.layout, "no layout")
    end
  end

  def print_all_events
    Event.find(:all, :order => :date).each {|event|
      p "#{event.date} #{event.name} #{event.id} #{event.parent_id} #{event.class} #{event.sanctioned_by} #{event.discipline}"
    }
  end
  
  def print_all_results
    Result.find(:all, :order => :racer_id).each {|result|
      p "#{result.place} #{result.name} #{result.team} #{result.event.name} #{result.race.name} #{result.date} BAR: #{result.bar}"
    }
  end
  
  def print_all_categories
    Category.find(:all, :order => 'parent_id, name').each {|category|
      p "#{category.id} #{category.parent_id} #{category.name}"
    }
  end
end
