# Mailing list post
class Post < ActiveRecord::Base
  includes Posts::Migration

  validates_presence_of :date
  validates_presence_of :from_email, :on => :create
  validates_presence_of :from_name, :on => :create
  validates_presence_of :mailing_list
  validates_presence_of :subject

  before_create :remove_list_prefix
  after_save :add_post_text

  belongs_to :mailing_list
  belongs_to :original, :class_name => "Post", :inverse_of => :replies
  has_one :post_text
  has_many :replies, :class_name => "Post", :inverse_of => :original, :foreign_key => :original_id

  scope :original, -> { where(:original_id => nil) }

  acts_as_list :scope => :mailing_list

  default_value_for(:date) { Time.zone.now }

  def self.remove_list_prefix(subject, subject_line_prefix)
    return "" unless subject
    subject.gsub(/\[#{subject_line_prefix}\]\s*/, "").strip
  end

  def self.strip_subject(subject)
    return "" unless subject

    subject.
      gsub(/\A(\s*)Re:(\s*)/i, "").
      gsub(/\A(\s*)Fw(d):(\s*)/i, "").
      gsub(/\s+/, " ").
      strip
  end

  def newer
    lower_item
  end

  def older
    higher_item
  end

  def remove_list_prefix
    if mailing_list
      self.subject = Post.remove_list_prefix(subject, mailing_list.subject_line_prefix)
    end
    subject
  end

  # Replace a couple letters from email addresses to avoid spammers
  def from_email_obscured
    return "" if from_email.blank?

    sender_parts = from_email.split("@")
    if sender_parts.size > 1
      person_name = sender_parts.first
      if person_name.length > 2
        return person_name[0..(person_name.length - 3)] + "..@" + sender_parts.last
      else
        return "..@" + sender_parts.last
      end
    end

    ""
  end

  def add_post_text
    updated_post_text = post_text(true) || build_post_text
    updated_post_text.text = subject
    updated_post_text.save
  end
end
