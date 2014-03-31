# Mailing list post
class Post < ActiveRecord::Base
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

  def self.add_replies!(mailing_list)
    # Optimize for large mailing list

    transaction do
      Post.update_all "last_reply_at = date"

      # Create hash of arrays of hashes keyed by name (subject)
      posts_by_subject = Hash.new

      # Need to use case-normalized subjects for key, but preserve original subject
      original_subjects = Hash.new

      connection.select_all(mailing_list.posts.select([:id, :date, :from_name, :subject])).each do |post|
        key = strip_subject(remove_list_prefix(post["subject"], mailing_list.subject_line_prefix)).strip.downcase
        posts = posts_by_subject[key] || []
        posts << post
        posts_by_subject[key] = posts

        original_subjects[key] = name unless original_subjects.has_key?(key)
      end

      posts_by_subject.each do |key, posts|
        if posts.size > 1
          posts = posts.sort_by { |post| post["position"].to_i }
          original = posts.first
          last_reply = posts.last
          Post.where(:id => original["id"]).update_all(
            :last_reply_at => last_reply["date"],
            :last_reply_from_name => last_reply["from_name"],
            :replies_count => posts.size - 1
          )
          reply_ids = posts.map { |post| post["id"] }
          reply_ids.delete original["id"]
          Post.where(:id => reply_ids).update_all(:original_id => original["id"])
        end
      end
    end

    true
  end

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
