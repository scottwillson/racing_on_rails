class RaceDayMailer < ActionMailer::Base
  def members_export(racers, sent_on_time = Time.now)
    subject    "#{ASSOCIATION.name} Members Export"
    recipients 'dcowley@sportsbaseonline.com'
    from       "scott@butlerpress.com"
    sent_on    sent_on_time
    
    body       :racers => racers
  end
end
