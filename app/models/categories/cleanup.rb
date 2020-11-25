# frozen_string_literal: true

module Categories
  module Cleanup
    extend ActiveSupport::Concern

    included do
      def self.cleanup!(commit_changes = true)
        transaction do
          logger.info "#{Category.count} categories before cleanup"

          destroy_unused!
          cleanup_names!

          logger.info "#{Category.count} categories after cleanup"

          raise ActiveRecord::Rollback unless commit_changes
        end
        true
      end

      def self.destroy_unused!
        Category.all.find_each do |category|
          unless category.in_use?
            logger.info "Destroy unused Category #{category.id} #{category.name}"
            category.destroy!
          end
        end
        true
      end

      def self.cleanup_names!
        # Whitespace cleanup deletes duplicate categories
        Category.all.find_each do |category|
          normalized_name = Category.normalized_name(category.name)
          next unless category.name != normalized_name
          existing_category = Category.where(name: normalized_name).where.not(id: category.id).first
          if existing_category
            category.replace_with existing_category
          else
            logger.info "Cleanup Category name from '#{category.name}' to '#{normalized_name}'"
            category.update! raw_name: normalized_name
          end
        end
        true
      end
    end

    def in_use?
      Category.where(parent_id: id).exists? ||
        Discipline.joins(:bar_categories).where("discipline_bar_categories.category_id" => id).exists? ||
        Race.where(category_id: id).exists? ||
        Result.where(category_id: id).exists?
    end

    def replace_with(existing_category)
      logger.info "Replace #{id} '#{name}' with #{existing_category.id} '#{existing_category.name}'"
      Category.where(parent_id: id).update_all(parent_id: existing_category.id)
      Discipline.connection.execute "update discipline_bar_categories set category_id = #{existing_category.id} where category_id = #{id}"
      Race.where(category_id: id).update_all(category_id: existing_category.id)
      Result.where(category_id: id).update_all(category_id: existing_category.id)
      destroy!
    end
  end
end
