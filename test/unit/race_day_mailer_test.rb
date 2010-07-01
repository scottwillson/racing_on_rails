require File.expand_path("../../test_helper", __FILE__)

class RaceDayMailerTest < ActionMailer::TestCase
  tests RaceDayMailer
  def test_members_export
    @expected.subject = "#{ASSOCIATION.name} Members Export"
    @expected.from    = "scott.willson@gmail.com"
    @expected.to      = "dcowley@sportsbaseonline.com"
    @expected.body    = read_fixture("members_export")
    now = Time.zone.now
    @expected.date    = now

    # Not asserting attachment, just checking that we don't get exception
    RaceDayMailer.create_members_export(Person.find_all_for_export, Time.zone.now)
  end
  
  def read_fixture(action)
    template = ERB.new(
        IO.readlines(File.join(RAILS_ROOT, 'test', 'fixtures', self.class.mailer_class.name.underscore, action)).join
    )
    template.result(binding)
  end
end
