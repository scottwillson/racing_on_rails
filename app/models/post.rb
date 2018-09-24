# frozen_string_literal: true

# Archived mailing list post
class Post < ApplicationRecord
  include Posts::Migration
  include Posts::Search

  validates :date, presence: true
  validates :from_email, presence: { on: :create }
  validates :from_name, presence: { on: :create }
  validates :mailing_list, presence: true
  validates :subject, presence: true

  validates :from_email, format: { with: /@/ }

  belongs_to :mailing_list
  belongs_to :original, class_name: "Post", inverse_of: :replies, counter_cache: :replies_count, optional: true
  has_many :replies, class_name: "Post", inverse_of: :original, foreign_key: :original_id

  scope :original, -> { where(original_id: nil) }

  acts_as_list scope: :mailing_list

  default_value_for(:date) { Time.zone.now }

  # Save new or updated Post to database.
  #
  # Associate reply posts with original and update original's reply count and last reply time.
  # Reposition original based on reply time. Build or update full text search index.
  #
  # In most cases, you want to call this service method, not just save! or create!
  def self.save(post, mailing_list)
    post.subject = Post.normalize_subject(post.subject, mailing_list.subject_line_prefix)

    transaction do
      original = find_original(post)
      if original
        original.replies << post
        original.last_reply_at = post.date if original.last_reply_at.nil? || post.date > original.last_reply_at
        original.save!
      end

      post.last_reply_at = post.date
      return false unless post.save

      original&.reposition!
      ApplicationController.expire_cache
    end

    true
  end

  def self.destroy(post)
    transaction do
      original = find_original(post)
      if original
        original.replies_count = original.replies_count - 1

        original.last_reply_at = if original.replies_count == 0
                                   original.date
                                 else
                                   original.replies.reject { |r| r == post }.sort_by(&:date).last.date
                                 end

        original.save
      end

      return false unless post.destroy

      original&.reposition!
      ApplicationController.expire_cache
    end

    true
  end

  # Find original post on this subject. Return nil if none.
  def self.find_original(post)
    subject = normalize_subject(post.subject, post.mailing_list.subject_line_prefix)
    posts = post.mailing_list.posts.where(subject: subject).original.order(:position)
    posts = posts.where("id != ?", post.id) unless post.new_record?
    posts.first
  end

  # Strip whitespace, mailing list prefix, and re: and fwd:
  def self.normalize_subject(subject, subject_line_prefix)
    strip_subject remove_list_prefix(subject, subject_line_prefix)
  end

  def self.remove_list_prefix(subject, subject_line_prefix)
    return "" unless subject
    subject.gsub(/\[#{subject_line_prefix}\]\s*/, "").strip
  end

  # Remove re: and fwd:
  def self.strip_subject(subject)
    return "" unless subject

    subject
      .gsub(/\A(\s*)Re:(\s*)/i, "")
      .gsub(/\A(\s*)Fw(d):(\s*)/i, "")
      .gsub(/\s+/, " ")
      .strip
  end

  # Last few Posts from all public MailingLists
  def self.recent
    # Use two queries, not an include for DB performance
    public_mailing_lists = MailingList.is_public
    Post.original.includes(:mailing_list).where(mailing_list: public_mailing_lists).order("position desc").limit(5)
  end

  # Move Post into position in list based on last_reply_at. In practice, most new Posts
  # move to the top of the list (highest position).
  def reposition!
    new_position = Post.where("last_reply_at <= ?", last_reply_at).order("position desc").pluck(:position).first
    insert_at new_position if new_position && new_position != position
  end

  # Next most-recent original Post
  def newer
    @newer ||= mailing_list.posts.original.order(:position).where("position > ?", position).first
  end

  # Next oldest original Post
  def older
    @older ||= mailing_list.posts.original.order("position desc").where("position < ?", position).first
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
end
