# frozen_string_literal: true

class SetCategoryAges < ActiveRecord::Migration
  def change
    Category.transaction do
      Category.where(ages_begin: 0, ages_end: 999).each(&:save!)
    end
  end
end
