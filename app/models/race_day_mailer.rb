# Send membership data to SportsBase
class RaceDayMailer < ActionMailer::Base
  def members_export(people, sent_on_time = Time.zone.now)
    subject    "#{ASSOCIATION.name} Members Export"
    recipients 'dcowley@sportsbaseonline.com'
    from       "scott.willson@gmail.com"
    sent_on    sent_on_time
    
    body "See attached file"
    
    attachment "text/plain" do |a|
      a.body = render(:file => "members_export", :body => { :people => people })
    end
  end
end
