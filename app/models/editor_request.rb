# +editor+ would like to become an editor for +person+. Sent in an email with link keyed by +token+.
# Sends email with link after_create. See EditorRequestMailer.
class EditorRequest < ActiveRecord::Base
  belongs_to :editor, :class_name => "Person"
  belongs_to :person
  
  validates_presence_of :editor
  validates_presence_of :email
  validates_presence_of :expires_at
  validates_presence_of :person
  validates_presence_of :token
  
  before_save :destroy_duplicates
  
  named_scope :expired, lambda { { :conditions => [ "expires_at <= ?", RacingAssociation.current.now ] } }
  
  # Set to expire in 1 week. Auto-set token.
  def before_validation
    self.email = person.try(:email)
    self.expires_at = 1.week.from_now
    self.token = Authlogic::Random.friendly_token
  end
  
  def destroy_duplicates
    EditorRequest.destroy_all :person_id => person_id, :editor_id => editor_id
  end
  
  # Send email
  def after_create
    EditorRequestMailer.deliver_request(self)
  end
  
  # Make +editor+ an editor of +person+
  def grant!
    unless person.editors.include?(editor)
      person.editors << editor
      EditorRequestMailer.deliver_notification(self)
    end
    destroy
  end
end
