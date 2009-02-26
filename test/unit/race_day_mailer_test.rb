require "test_helper"

class RaceDayMailerTest < ActionMailer::TestCase
  tests RaceDayMailer
  def test_members_export
    @expected.subject = "#{ASSOCIATION.name} Members Export"
    @expected.from    = "scott@butlerpress.com"
    @expected.to      = "dcowley@sportsbaseonline.com"
    @expected.body    = read_fixture("members_export")
    @expected.date    = Time.now

    assert_equal @expected.encoded, RaceDayMailer.create_members_export(Racer.find_all_for_export).encoded
  end
  
  def read_fixture(action)
    template = ERB.new(
        IO.readlines(File.join(RAILS_ROOT, 'test', 'fixtures', self.class.mailer_class.name.underscore, action)).join
    )
    template.result(binding)
  end
end
