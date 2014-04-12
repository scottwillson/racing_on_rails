require_relative "../test_helper"

# :stopdoc:
class RaceDayMailerTest < ActionMailer::TestCase
  tests RaceDayMailer

  def test_members_export
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:cyclocross_discipline)
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Track")

    @expected.subject = "#{RacingAssociation.current.name} Members Export"
    @expected.from    = "scott.willson@gmail.com"
    @expected.to      = "dcowley@sportsbaseonline.com"
    @expected.body    = read_fixture("members_export")
    now = Time.zone.now
    @expected.date    = now

    # Not asserting attachment, just checking that we don't get exception
    RaceDayMailer.members_export Person.find_all_for_export
  end
  
  def read_fixture(action)
    template = ERB.new(
        IO.readlines(File.join(::Rails.root.to_s, 'test', 'fixtures', self.class.mailer_class.name.underscore, action)).join
    )
    template.result(binding)
  end
end
