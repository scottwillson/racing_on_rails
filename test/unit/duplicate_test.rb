require File.dirname(__FILE__) + '/../test_helper'

class DuplicateTest < ActiveSupport::TestCase
  def test_create
    new_racer = {:first_name => 'Magnus', :last_name => 'Tonkin'}
    Duplicate.create!(:new_attributes => new_racer, :racers => [racers(:tonkin), racers(:alice)])
    dupes = Duplicate.find(:all)
    assert_equal(1, dupes.size, 'Dupes')
    dupe = dupes.first
    assert_not_nil(dupe.new_attributes, 'dupe.new_racer')
    assert_not_nil(dupe.new_attributes, 'dupe.new_attributes')
    assert_equal(new_racer, dupe.new_attributes)
    assert_equal([racers(:tonkin), racers(:alice)], dupe.racers, 'racers')
  end
end
