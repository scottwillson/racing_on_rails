# Send membership data to SportsBase
class RaceDayMailer < ActionMailer::Base
  def members_export(people, sent_on_time = Time.zone.now)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    subject    "#{RacingAssociation.current.name} Members Export"
    recipients 'dcowley@sportsbaseonline.com'
    from       "scott.willson@gmail.com"
    sent_on    sent_on_time
    
    body "See attached file"
    
    attachment "text/plain" do |a|
      a.body = render(:file => "members_export", :body => { :people => people })
    end
  end
end
