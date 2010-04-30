require "test_helper"

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

  
  private
  
  def current_person
    @current_person
  end
end
