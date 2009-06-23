class RaceDayMailer < ActionMailer::Base
  def members_export(people, sent_on_time = Time.now)
    subject    "#{ASSOCIATION.name} Members Export"
    recipients 'dcowley@sportsbaseonline.com'
    from       "scott@butlerpress.com"
    sent_on    sent_on_time
    
    body "See attached file"
    
    attachment "text/plain" do |a|
      a.body = render(:file => "members_export", :body => { :people => people })
    end

  end
end
