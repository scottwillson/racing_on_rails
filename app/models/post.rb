# Mailing list post
class Post < ActiveRecord::Base

  attr_accessor :from_email_address, :from_name

  validates_presence_of :subject, :body, :date, :from_name, :mailing_list_id, :from_email_address
  before_save :remove_list_prefix

  belongs_to :mailing_list
  
  def Post.find_for_dates(mailing_list, month_start, month_end)
    logger.debug("Post.find_for_dates(#{mailing_list}, #{month_start}, #{month_end})")
    mailing_list.posts.find(
      :all,
      :select => "id, date, sender, subject, topica_message_id" ,
      :conditions => [ "date between ? and ?", month_start, month_end ],
      :order => "date desc"
    )
  end
  
  def initialize(attributes = nil)
    super
    self.date = Time.zone.now if date.nil?
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
    
    return sender
  end
  
  def update_sender
    if @from_name.present? && from_email_address.present? && @from_email_address.present? && !(@from_name.to_s == @from_email_address.to_s )
      self.sender = "#{@from_name} <#{@from_email_address}>"
    else
      self.sender = @from_email_address.to_s
    end
  end
end
