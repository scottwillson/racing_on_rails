require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class DuplicateTest < ActiveSupport::TestCase
  def test_create
    new_person = {:first_name => 'Magnus', :last_name => 'Tonkin'}
    Duplicate.create!(:new_attributes => new_person, :people => [people(:tonkin), people(:alice)])
    dupes = Duplicate.find.all()
    assert_equal(1, dupes.size, 'Dupes')
    dupe = dupes.first
    assert_not_nil(dupe.new_attributes, 'dupe.new_person')
    assert_not_nil(dupe.new_attributes, 'dupe.new_attributes')
    assert_equal(new_person, dupe.new_attributes)
    assert_equal([people(:tonkin), people(:alice)], dupe.people, 'people')
  end
end
