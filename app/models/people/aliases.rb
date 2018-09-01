# frozen_string_literal: true

module People
  module Aliases
    extend ActiveSupport::Concern

    included do
      before_save :destroy_shadowed_aliases
      around_save :add_alias_for_old_name

      has_many :aliases, as: :aliasable, dependent: :destroy
    end

    # If name changes to match existing alias, destroy the alias
    def destroy_shadowed_aliases
      Alias.where(name: name).destroy_all if first_name_changed? || last_name_changed?
    end

    def add_alias_for_old_name
      previous_name = name_was

      yield

      if !new_record? &&
         previous_name.present? &&
         name.present? &&
         previous_name.casecmp(name) != 0 &&
         !Alias.exists?(name: previous_name, aliasable_id: id, aliasable_type: "Person") &&
         !Person.exists?(name: previous_name)

        new_alias = Alias.new(name: previous_name, person: self)
        unless new_alias.save
          errors :aliases, "Could not save alias #{new_alias}: #{new_alias.errors.full_messages.join(', ')}"
          throw :abort
        end
        new_alias
      end
    end
  end
end
