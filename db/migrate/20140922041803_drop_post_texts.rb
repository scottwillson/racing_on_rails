# frozen_string_literal: true

class DropPostTexts < ActiveRecord::Migration
  def change
    drop_table :post_texts
  end
end
