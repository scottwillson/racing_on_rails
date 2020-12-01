# frozen_string_literal: true

# +editor+ would like to become an editor for +person+. Sent in an email with link keyed by +token+.
# Sends email with link after_create. See EditorRequestMailer.
class EditorRequest < ApplicationRecord
  belongs_to :editor, class_name: "Person"
  belongs_to :person

  before_validation :set_email, :set_expires_at, :set_token
  before_save :destroy_duplicates
  after_create :send_email

  validates :editor, presence: true
  validates :email, presence: true
  validates :expires_at, presence: true
  validates :person, presence: true
  validates :token, presence: true

  scope :expired, -> { where("expires_at <= ?", Time.zone.now) }

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
    EditorRequest.where(person_id: person_id, editor_id: editor_id).destroy_all
  end

  def send_email
    EditorRequestMailer.editor_request(self).deliver_now
  end

  # Make +editor+ an editor of +person+
  def grant!
    unless person.editors.include?(editor)
      person.editors << editor
      EditorRequestMailer.notification(self).deliver_now
    end
    destroy
  end
end
