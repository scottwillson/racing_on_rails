# +editor+ would like to become an editor for +person+. Sent in an email with link keyed by +token+.
# Sends email with link after_create. See EditorRequestMailer.
class EditorRequest < ActiveRecord::Base
  belongs_to :editor, :class_name => "Person"
  belongs_to :person
  
  before_validation :set_email, :set_expires_at, :set_token
  after_create :send_email
  
  validates_presence_of :editor
  validates_presence_of :email
  validates_presence_of :expires_at
  validates_presence_of :person
  validates_presence_of :token
  
  before_save :destroy_duplicates
  
  scope :expired, lambda { { :conditions => [ "expires_at <= ?", RacingAssociation.current.now ] } }
  
  def set_email
    self.email = person.try(:email)
  end
  
  def set_expires_at
    self.expires_at = 1.week.from_now
  end
  
  def set_token
    self.token = Authlogic::Random.friendly_token
  end
  
  def destroy_duplicates
    EditorRequest.destroy_all :person_id => person_id, :editor_id => editor_id
  end
  
  def send_email
    EditorRequestMailer.request(self).deliver
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
