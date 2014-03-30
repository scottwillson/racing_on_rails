# Mailing list post
class Post < ActiveRecord::Base

  attr_accessor :from_email_address, :from_name

  validates_presence_of :subject, :date, :mailing_list
  validates_presence_of :from_name, :from_email_address

  before_create :remove_list_prefix, :update_sender
  after_save :add_post_text

  belongs_to :mailing_list
  has_one :post_text

  acts_as_list :scope => :mailing_list

  default_value_for(:date) { Time.zone.now }

  # acts_as_list puts the first post in the "first"/"top" position with a position of 1
  # Behavior is different if position has a default value other than null
  # Databases looks like (date, position):
  # 2012-07-01  1
  # 2012-07-05  2
  # 2012-07-05  3
  # 2012-07-08  4
  def self.reposition!(mailing_list)
    # Optimize for large mailing list
    transaction do
      connection.select_all(mailing_list.posts.select([:id, :date]).order(:date)).each.with_index do |post, index|
        Post.where(:id => post["id"]).update_all(:position => index + 1)
      end
    end
  end

  def newer
    lower_item
  end

  def older
    higher_item
  end
 
  def from_name
    @from_name ||= (
    if sender
      if sender["<"]
        sender[/^([^<]+)/].try(:strip)
      elsif !sender["@"]
        sender
      end
    end
    )
  end

  def from_email_address
    @from_email_address ||= (
    if sender
      if sender["<"]
        sender[/<(.*)>/, 1].try(:strip)
      elsif !sender["<"]
        sender
      end
    end
    )
  end

  def sender=(value)
    self[:sender] = value
  end

  def remove_list_prefix
    subject.gsub!(/\[#{mailing_list.subject_line_prefix}\]\s*/, "")
    subject.strip!
  end

  def from_email_address=(value)
    @from_email_address = value
    update_sender
  end

  def topica?
    topica_message_id.present?
  end

  def from_name=(value)
    @from_name = value
    update_sender
  end

  # Replace a couple letters from email addresses to avoid spammers
  def sender_obscured
    if sender.blank? or !topica_message_id.blank?
      return sender
    end

    sender_parts = sender.split("@")
    if sender_parts.size > 1
      person_name = sender_parts.first
      if person_name.length > 2
        return person_name[0..(person_name.length - 3)] + "..@" + sender_parts.last
      else
        return "..@" + sender_parts.last
      end
    end

    sender
  end

  def update_sender
    if @from_name.present? && from_email_address.present? && @from_email_address.present? && !(@from_name.to_s == @from_email_address.to_s )
      self.sender = "#{@from_name} <#{@from_email_address}>"
    else
      self.sender = @from_email_address.to_s
    end
  end

  def add_post_text
    updated_post_text = post_text(true) || build_post_text
    updated_post_text.text = subject
    updated_post_text.save
  end
end
