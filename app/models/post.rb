class Post < ActiveRecord::Base

  attr_accessor :from_email_address, :from_name

  validates_presence_of :subject, :body, :date, :from_name, :mailing_list_id, :from_email_address
  before_save :remove_list_prefix

  belongs_to :mailing_list
  
  def Post.find_for_dates(mailing_list, month_start, month_end)
    Post.find_by_sql(
      ["select id, date, sender, subject, topica_message_id from posts where mailing_list_id = ? and date >= ? and date <= ? order by date desc",
        mailing_list.id, month_start, month_end])
  end
  
  def initialize(attributes = nil)
    super
    self.date = Time.now if date.nil?
  end
  
  def add_time
    if (date.hour == 0 or date.hour == 12) and date.min == 0 and date.sec == 0
      self.date = date + id    
    end
  end
  
  def remove_list_prefix
    subject.gsub!(/\[#{mailing_list.subject_line_prefix}\]\s*/, "")
    subject.strip!
  end
  
  def remove_topica_footer
    return if body.blank?
    self.body = body.gsub(/<map name=\'unsubbed_gray_map\'.*<img[^>]+>/m, "")
  end

  def from_email_address=(value)
    @from_email_address = value
    update_sender
  end

  def from_name=(value)
    @from_name = value
    update_sender
  end
  
  def sender_obscured
    if sender.blank? or !topica_message_id.blank?
      return sender
    end
    
    sender_parts = sender.split("@")
    if sender_parts.size > 1
      user_name = sender_parts.first
      if user_name.length > 2
        return user_name[0..(user_name.length - 3)] + "..@" + sender_parts.last
      else
        return "..@" + sender_parts.last
      end
    end
    
    return sender
  end
  
  def topica?
    !topica_message_id.blank?
  end
  
  def update_sender
    if !@from_name.blank? and from_email_address and !@from_email_address.empty? and !(@from_name.to_s == @from_email_address.to_s )
      self.sender = "#{@from_name} <#{@from_email_address}>"
    else
      self.sender = @from_email_address.to_s
    end
  end

end
