require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class DisciplineTest < ActiveSupport::TestCase
  def test_find_by_symbol
    discipline = FactoryGirl.create(:discipline, name: "Road")
    assert_equal discipline, Discipline[:road], "Road"
  end

  def test_find_via_alias
    cyclocross = FactoryGirl.create(:discipline, name: "Cyclocross")
    FactoryGirl.create(:discipline_alias, discipline: cyclocross, alias: "cx")

    road = FactoryGirl.create(:discipline, name: "Road")

    assert_equal road, Discipline.find_via_alias("Road"), "Road by alias"
    assert_equal road, Discipline.find_via_alias("road"), "road by alias"
    assert_equal cyclocross, Discipline.find_via_alias("Cyclocross"), "Cyclocross by alias"
    assert_equal cyclocross, Discipline.find_via_alias("cyclocross"), "cyclocross by alias"
    assert_equal cyclocross, Discipline.find_via_alias("cx"), "cyclocross by alias"
  end

  def test_instance_names
    assert_equal(%w{ Circuit }, Discipline.new(name: "Circuit").names, "Circuit names")
    assert_equal(["Downhill", "Mountain Bike", "Super D", "Short Track"], Discipline.new(name: "Mountain Bike").names, "Mountain Bike names")
    assert_equal(["Downhill"], Discipline.new(name: "Downhill").names, "Downhill names")
  end

  def test_class_names
    FactoryGirl.create(:discipline, name: "Road")
    FactoryGirl.create(:discipline, name: "Track")
    assert_equal [ "Road", "Track" ], Discipline.names.sort, "name"
  end
end
