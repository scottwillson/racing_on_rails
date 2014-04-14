require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleHelperTest < ActionView::TestCase
  test "administrator" do
    assert !administrator?, "administrator? with no one logged-in"
  end

  test "administrator not admin" do
    @current_person = Person.new
    assert !administrator?, "administrator? with no one logged-in"
  end

  test "administrator admin" do
    @current_person = FactoryGirl.create(:administrator)
    assert administrator?, "administrator? with no one logged-in"
  end

  test "administrator promoter" do
    @current_person = FactoryGirl.create(:promoter)
    assert !administrator?, "administrator? with no one logged-in"
  end

  test "promoter" do
    assert !promoter?, "promoter? with no one logged-in"
  end

  test "promoter person" do
    @current_person = Person.new
    assert !promoter?, "promoter? with no one logged-in"
  end

  test "promoter person promoter" do
    @current_person = FactoryGirl.create(:promoter)
    assert promoter?, "promoter? with no one logged-in"
  end

  test "pronoun" do
    weaver = FactoryGirl.create(:person, first_name: "Ryan", last_name: "Weaver")
    tonkin = FactoryGirl.create(:person, first_name: "Erik", last_name: "Tonkin")
    assert_equal "Ryan Weaver", pronoun(weaver, tonkin)
    assert_equal "me", pronoun(weaver, weaver)
    assert_equal "me", pronoun(tonkin, tonkin)
    assert_equal "Erik Tonkin", pronoun(tonkin, weaver)
  end


  private

  def current_person
    @current_person
  end
end
