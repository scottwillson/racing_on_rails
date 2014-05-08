module Categories
  module Cleanup
    extend ActiveSupport::Concern

    included do
      def self.cleanup!(commit_changes = true)
        transaction do
          logger.debug "#{Category.count} categories before cleanup"

          destroy_unused!
          cleanup_names!

          logger.debug "#{Category.count} categories after cleanup"

          raise ActiveRecord::Rollback unless commit_changes
        end
        true
      end

      def self.destroy_unused!
        Category.all.each do |category|
          if !category.in_use?
            logger.debug "Destroy unused Category #{category.id} #{category.name}"
            category.destroy!
          end
        end
        true
      end

      def self.cleanup_names!
        # Whitespace cleanup deletes duplicate categories
        Category.all.each do |category|
          normalized_name = Category.normalized_name(category.name)
          if category.name != normalized_name
            existing_category = Category.where(name: normalized_name).where.not(id: category.id).first
            if existing_category
              category.replace_with existing_category
            else
              logger.debug "Cleanup Category name from '#{category.name}' to '#{normalized_name}'"
              category.update! raw_name: normalized_name
            end
          end
        end
        true
      end
    end

    def in_use?
      Category.where(parent_id: id).exists? ||
      Discipline.joins(:bar_categories).where("discipline_bar_categories.category_id" => id).exists? ||
      Race.where(category_id: id).exists? ||
      RacingAssociation.current.cat4_womens_race_series_category == self ||
      Result.where(category_id: id).exists?
    end

    def replace_with(existing_category)
      logger.debug "Replace #{id} '#{name}' with #{existing_category.id} '#{existing_category.name}'"
      Category.where(parent_id: id).update_all(parent_id: existing_category.id)
      Discipline.connection.execute "update discipline_bar_categories set category_id = #{existing_category.id} where category_id = #{id}"
      Race.where(category_id: id).update_all(category_id: existing_category.id)
      RacingAssociation.where(cat4_womens_race_series_category_id: id).update_all(cat4_womens_race_series_category_id: existing_category.id)
      Result.where(category_id: id).update_all(category_id: existing_category.id)
      destroy!
    end
  end
end
