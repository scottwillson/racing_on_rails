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
    assert_equal "Ryan Weaver", pronoun(people(:weaver), people(:tonkin))
    assert_equal "me", pronoun(people(:weaver), people(:weaver))
    assert_equal "me", pronoun(people(:tonkin), people(:tonkin))
    assert_equal "Erik Tonkin", pronoun(people(:tonkin), people(:weaver))
  end

  
  private
  
  def current_person
    @current_person
  end
end
