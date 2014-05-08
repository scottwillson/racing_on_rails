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
        Category.all.each(&:cleanup_whitespace!)
        Category.all.each(&:cleanup_case!)
        Category.all.each(&:cleanup_name!)
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

    def cleanup_whitespace!
      normalized_name = Category.strip_whitespace(name)
      if name != normalized_name
        existing_category = Category.where(name: normalized_name).where.not(id: id).first
        if existing_category
          replace_with existing_category
        else
          logger.debug "Cleanup Category name whitespace from '#{name}' to '#{normalized_name}'"
          update! raw_name: normalized_name
        end
      end
    end

    def cleanup_case!
      cleaned_name = Category.cleanup_case(name)
      if cleaned_name != name
        logger.debug "Cleanup Category case from '#{name}' to '#{cleaned_name}'"
        update! raw_name: cleaned_name
      end
    end

    def cleanup_name!
      normalized_name = Category.normalized_name(name)
      if name != normalized_name
        existing_category = Category.where(name: normalized_name).where.not(id: id).first
        if existing_category
          replace_with existing_category
        else
          logger.debug "Cleanup Category name normalized_name from '#{name}' to '#{normalized_name}'"
          update! raw_name: normalized_name
        end
      end
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
