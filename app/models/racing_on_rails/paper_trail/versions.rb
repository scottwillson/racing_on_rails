# frozen_string_literal: true

module RacingOnRails::PaperTrail::Versions
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: "RacingOnRails::PaperTrail::Version",
                    ignore: %i[
                               created_at
                               created_by_paper_trail_id
                               created_by_paper_trail_name
                               created_by_paper_trail_type
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
                               updated_by_paper_trail_id
                               updated_by_paper_trail_name
                               updated_by_paper_trail_type
                             ],
                    versions: :paper_trail_versions,
                    version:  :paper_trail_version

    before_save :set_created_by_paper_trail
    before_save :set_updated_by_paper_trail
  end

  def current_updater
    updater || ::Person.current
  end

  def paper_trail_name_or_login(updater)
    if updater.respond_to?(:name_or_login)
      updater.name_or_login
    else
      updater&.name
    end
  end

  def set_created_by_paper_trail
    return true if created_by_paper_trail_name

    self.created_by_paper_trail_id = current_updater&.id
    self.created_by_paper_trail_name = paper_trail_name_or_login(current_updater)
    self.created_by_paper_trail_type = current_updater&.class&.name

    true
  end

  def set_updated_by_paper_trail
    self.updated_by_paper_trail_id = current_updater&.id
    self.updated_by_paper_trail_name = paper_trail_name_or_login(current_updater)
    self.updated_by_paper_trail_type = current_updater&.class&.name

    true
  end
end
