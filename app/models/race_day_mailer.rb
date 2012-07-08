# Send membership data to SportsBase
class RaceDayMailer < ActionMailer::Base
  helper :application

  def members_export(people)
    mail(
      subject: "#{RacingAssociation.current.name} Members Export",
      recipients: 'dcowley@sportsbaseonline.com',
      from: "scott.willson@gmail.com",
      body: "See attached file"
    )

    @people = people
  end
end
