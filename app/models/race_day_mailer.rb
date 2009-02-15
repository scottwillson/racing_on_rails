class RaceDayMailer < ActionMailer::Base
  def members_export(racers)
    subject    "#{ASSOCIATION.name} Members Export"
    recipients ''
    from       "scott@butlerpress.com"
    sent_on    Time.now
    
    body       :racers => racers
  end
end
