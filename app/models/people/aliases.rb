module People
  module Aliases
    extend ActiveSupport::Concern

    included do
      before_save :destroy_shadowed_aliases
      after_save :add_alias_for_old_name

      has_many :aliases, as: :aliasable, dependent: :destroy
    end

    # If name changes to match existing alias, destroy the alias
    def destroy_shadowed_aliases
      Alias.destroy_all(['name = ?', name]) if first_name_changed? || last_name_changed?
    end

    def add_alias_for_old_name
      if !new_record? &&
         name_was.present? &&
         name.present? &&
         name_was.casecmp(name) != 0 &&
         !Alias.exists?(['name = ? and aliasable_id = ? and aliasable_type = ?', name_was, id, "Person"]) &&
         !Person.exists?(["name = ?", name_was])

        new_alias = Alias.new(name: name_was, person: self)
        unless new_alias.save
          logger.error "Could not save alias #{new_alias}: #{new_alias.errors.full_messages.join(', ')}"
        end
        new_alias
      end
    end
  end
end
