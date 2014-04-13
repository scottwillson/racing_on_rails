# Mailman archives
class MailingList < ActiveRecord::Base

  has_many :posts

  # Range of first Post date and last post date
  # Return nil..nil if no Posts
  # Cache SQL results
  # Hack: Just finds first and last post in ENTIRE table. Incorrect,
  # but 50+ times faster
  def dates
    if @dates.nil?
      first_post = MailingList.connection.select_value("select min(date) from posts")
      if first_post
        last_post = MailingList.connection.select_value("select max(date) from posts")
        @dates = first_post..last_post
      end
    end
    return @dates
  end

  def reload
    super
    @dates = nil
  end

  def to_s
    "<#{self.class} #{id} #{name} #{friendly_name}>"
  end
end
