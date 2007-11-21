require File.dirname(__FILE__) + '/../test_helper'

# Test email for first race

class OregonCupMailerTest < ActionMailer::TestCase

  def test_kickoff
    expected = TMail::Mail.new
    expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    expected.subject = "Oregon Cup Starts This Weekend"
    expected.from = "Scott Willson <scott@butlerpress.com>"
    expected.to = 'obra@list.obra.org'
    expected.body = read_fixture("kickoff")
    expected.mime_version = '1.0'

    or_cup = OregonCup.create(:date => Date.new(2004))
    or_cup.events << events(:banana_belt_1)
    or_cup.events << events(:kings_valley_2004)
    or_cup.save!
    OregonCup.recalculate(2004)
    kickoff_email = OregonCupMailer.create_kickoff(Date.new(2004, 2, 2))
    
    assert_equal(expected.encoded, kickoff_email.encoded)
  end

  def test_standings
    expected = TMail::Mail.new
    expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    expected.subject = "Oregon Cup Standings"
    expected.from = "Scott Willson <scott@butlerpress.com>"
    expected.to = 'obra@list.obra.org'
    expected.body = read_fixture("standings")
    expected.mime_version = '1.0'

    kings_valley_2004 = events(:kings_valley_2004)
    or_cup = OregonCup.create(:date => Date.new(2004))
    or_cup.events << events(:banana_belt_1)
    or_cup.events << kings_valley_2004
    or_cup.save!
    OregonCup.recalculate(2004)
    standings_email = OregonCupMailer.create_standings(kings_valley_2004.date - 3)
    
    assert_equal(expected.encoded, standings_email.encoded)
  end

  def test_final_standings
    expected = TMail::Mail.new
    expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    expected.subject = "Oregon Cup Standings"
    expected.from = "Scott Willson <scott@butlerpress.com>"
    expected.to = 'obra@list.obra.org'
    expected.body = read_fixture("final_standings")
    expected.mime_version = '1.0'

    or_cup = OregonCup.create(:date => Date.new(2004))
    or_cup.events << events(:banana_belt_1)
    or_cup.events << events(:kings_valley_2004)
    or_cup.save!
    OregonCup.recalculate(2004)
    standings_email = OregonCupMailer.create_standings(Date.new(2004, 12, 31))
    
    assert_equal(expected.encoded, standings_email.encoded)
  end
end