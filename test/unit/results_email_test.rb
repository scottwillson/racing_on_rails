require File.dirname(__FILE__) + '/../test_helper'

class ResultsEmailTest < Test::Unit::TestCase

  def test_render
    results_email = ResultsEmail.new(Standings.find(1))
    text = results_email.text
    expected = <<END
Banana Belt I

Senior Men Pro 1/2
  1         Erik Tonkin                 Kona                        
  2         Ryan Weaver                                             
  3         Mark Matson                 Kona                        
 16         Mollie Cameron              Vanilla
END
    assert_equal(expected, results_email.text, "results email text")
  end
  
end