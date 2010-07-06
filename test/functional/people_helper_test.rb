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
    @current_person = people(:administrator)
    assert administrator?, "administrator? with no one logged-in"
  end

  def test_administrator_promoter
    @current_person = people(:promoter)
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
    @current_person = people(:promoter)
    assert promoter?, "promoter? with no one logged-in"
  end

  def test_pronoun
    person_1 = Person.new(:name => "Tiny")
    person_2 = Person.new(:name => "Buddy")
    assert_equal "Tiny", pronoun(person_1, person_2)
    assert_equal "me", pronoun(person_1, person_1)
    assert_equal "me", pronoun(person_2, person_2)
    assert_equal "Buddy", pronoun(person_2, person_1)
  end

  
  private
  
  def current_person
    @current_person
  end
end
