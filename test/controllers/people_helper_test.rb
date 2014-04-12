require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleHelperTest < ActionView::TestCase
  def test_administrator
    assert !administrator?, "administrator? with no one logged-in"
  end

  def test_administrator_not_admin
    @current_person = Person.new
    assert !administrator?, "administrator? with no one logged-in"
  end

  def test_administrator_admin
    @current_person = FactoryGirl.create(:administrator)
    assert administrator?, "administrator? with no one logged-in"
  end

  def test_administrator_promoter
    @current_person = FactoryGirl.create(:promoter)
    assert !administrator?, "administrator? with no one logged-in"
  end

  def test_promoter
    assert !promoter?, "promoter? with no one logged-in"
  end

  def test_promoter_person
    @current_person = Person.new
    assert !promoter?, "promoter? with no one logged-in"
  end

  def test_promoter_person_promoter
    @current_person = FactoryGirl.create(:promoter)
    assert promoter?, "promoter? with no one logged-in"
  end
  
  def test_pronoun
    weaver = FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver")
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
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
