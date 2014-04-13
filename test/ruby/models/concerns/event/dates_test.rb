require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/dates", __FILE__)

# :stopdoc:
class Concerns::Event::DatesTest < Ruby::TestCase
  class TestEvent
    def self.before_save(symbol)
    end

    include Concerns::Event::Dates

    attr_accessor :date
    attr_accessor :end_date
  end

  def test_short_date
    event = TestEvent.new

    event.date = Date.new(2006, 9, 9)
    assert_equal(' 9/9 ', event.short_date, 'Short date')

    event.date = Date.new(2006, 9, 10)
    assert_equal(' 9/10', event.short_date, 'Short date')

    event.date = Date.new(2006, 10, 9)
    assert_equal('10/9 ', event.short_date, 'Short date')

    event.date = Date.new(2006, 10, 10)
    assert_equal('10/10', event.short_date, 'Short date')
  end
end
