require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/dates", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/names", __FILE__)

# :stopdoc:
class Concerns::Event::NamesTest < Ruby::TestCase
  class TestEvent
    include Concerns::Event::Dates
    include Concerns::Event::Names
    
    attr_accessor :date, :name, :children, :parent, :parent_id
    
    def initialize(attributes)
      self.date = attributes[:date]
      self.name = attributes[:name]
      self.parent = attributes[:parent]
      if parent
        self.parent_id = 2
      end
      self.children = []
    end
  end

  def test_full_name
    event = TestEvent.new(:name => 'Reheers')
    assert_equal('Reheers', event.full_name, 'full_name')
    
    series = TestEvent.new(:name => 'Bend TT Series')
    series_event = TestEvent.new(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19), :parent => series)
    assert_equal('Bend TT Series', series_event.full_name, 'full_name when series name is same as event')

    stage_race = TestEvent.new(:name => 'Mt. Hood Classic')
    stage = TestEvent.new(:name => "Mt. Hood Classic", :parent => stage_race)
    assert_equal('Mt. Hood Classic', stage.full_name, 'stage race stage full_name')

    stage = TestEvent.new(:name => "Cooper Spur Road Race", :parent => stage_race)
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race', stage.full_name, 'stage race event full_name')

    stage_race = TestEvent.new(:name => 'Cascade Classic')
    stage = TestEvent.new(:name => "Cascade Classic - Cascade Lakes Road Race", :parent => stage_race)
    assert_equal('Cascade Classic - Cascade Lakes Road Race', stage.full_name, 'stage race results full_name')

    stage_race = TestEvent.new(:name => 'Frozen Flatlands Omnium')
    stage = TestEvent.new(:name => "Frozen Flatlands Time Trial", :parent => stage_race)
    assert_equal('Frozen Flatlands Omnium: Frozen Flatlands Time Trial', stage.full_name, 'stage race results full_name')
  end
  
  def test_full_name_with_date
    event = TestEvent.new(:name => 'Reheers', :date => Date.new(2010, 1, 2))
    assert_equal('Reheers (1/2)', event.full_name_with_date, 'full_name')
    
    series = TestEvent.new(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    series_event = TestEvent.new(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19), :parent => series)
    assert_equal('Bend TT Series (4/19)', series_event.full_name_with_date, 'full_name when series name is same as event')

    stage_race = TestEvent.new(:name => "Mt. Hood Classic")
    stage = TestEvent.new(:name => "Mt. Hood Classic", :date => Date.new(2009, 4, 19), :parent => stage_race)
    assert_equal('Mt. Hood Classic (4/19)', stage.full_name_with_date, 'stage race stage full_name')

    stage_race = TestEvent.new(:name => "Mt. Hood Classic")
    stage = TestEvent.new(:name => "Cooper Spur Road Race", :date => Date.new(2009, 4, 19), :parent => stage_race)
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race (4/19)', stage.full_name_with_date, 'stage race event full_name')
  end
end