# frozen_string_literal: true

class AddRejected < ActiveRecord::Migration[5.2]
  def change
    change_table :races, bulk: true, force: true do |t|
      t.boolean :rejected
      t.string :rejection_reason
    end

    change_table :results, bulk: true, force: true do |t|
      t.boolean :rejected
      t.string :rejection_reason
    end

    change_table :result_sources, bulk: true, force: true do |t|
      t.boolean :rejected
    end
  end
end
