# frozen_string_literal: true

module RacingOnRails::PaperTrail::Versions
  extend ActiveSupport::Concern

  included do
    # Record (usually Person but can be ImportFile, Event, etc.) about to make this update.
    # Need separate attribute from updated_by to differentiate from previous, stored updated_by and new updated_by.
    attr_accessor :updater

    has_paper_trail ignore: %i[
                               created_at
                               created_by_id
                               created_by_name
                               created_by_type
                               current_login_at
                               current_login_ip
                               last_login_at
                               last_login_ip
                               login_count
                               password_salt
                               perishable_token
                               persistence_token
                               single_access_token
                               updated_at
                               updated_by_id
                               updated_by_name
                               updated_by_type
                             ]

    before_save :set_created_by
    before_save :set_updated_by
  end

  def current_updater
    updater || ::Person.current
  end

  def updater_name_or_login(updater)
    if updater.respond_to?(:name_or_login)
      updater.name_or_login
    else
      updater&.name
    end
  end

  def set_created_by
    return true if created_by_name

    self.created_by_id = current_updater&.id
    self.created_by_name = updater_name_or_login(current_updater)
    self.created_by_type = current_updater&.class&.name

    true
  end

  def set_updated_by
    self.updated_by_id = current_updater&.id
    self.updated_by_name = updater_name_or_login(current_updater)
    self.updated_by_type = current_updater&.class&.name

    true
  end

  def created_by
    begin
      created_by_type&.constantize&.find(created_by_id)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def updated_by
    begin
      updated_by_type&.constantize&.find(updated_by_id)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def created_from_result?
    created_by&.is_a? ::Event
  end

  def updated_after_created?
    created_at && updated_at && ((updated_at - created_at) > 1.hour)
  end

  def never_updated?
    !updated_after_created?
  end
end
