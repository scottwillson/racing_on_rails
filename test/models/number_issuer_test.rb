# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class NumberIssuerTest < ActiveSupport::TestCase
  test "create" do
    NumberIssuer.create(name: "Elkhorn Classic SR")
    assert_not(NumberIssuer.new.valid?, "Null name")
    assert_not(NumberIssuer.new(name: "").valid?, "Empty name")
  end
end
