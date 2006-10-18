require File.dirname(__FILE__) + '/../test_helper'

class NumberIssuerTest < Test::Unit::TestCase

  def test_create
    NumberIssuer.create(:name => 'Elkhorn Classic SR')
    assert(!NumberIssuer.new.valid?, 'Null name')
    assert(!NumberIssuer.new(:name => '').valid?, 'Empty name')
  end
end