require "minitest/autorun"
require File.expand_path("../../../lib/test/enumerable_assertions", __FILE__)
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/try"
require "active_support/concern"
require "mocha/setup"

module Ruby
  class TestCase < Minitest::Test
    include Test::EnumerableAssertions
  end
end
