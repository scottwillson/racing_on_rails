class AddCreatedAndUpdatedBy < ActiveRecord::Migration
  def change
    change_table :discount_codes do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :events do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :pages do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :people do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :race_numbers do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :races do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :refunds do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    change_table :teams do |t|
      t.integer :created_by_paper_trail_id, default: nil
      t.string :created_by_paper_trail_type, default: nil
      t.integer :updated_by_paper_trail_id, default: nil
      t.string :updated_by_paper_trail_type, default: nil
    end

    add_index :discount_codes, :created_by_paper_trail_id
    add_index :discount_codes, :updated_by_paper_trail_id

    add_index :events, :created_by_paper_trail_id
    add_index :events, :updated_by_paper_trail_id

    add_index :pages, :created_by_paper_trail_id
    add_index :pages, :updated_by_paper_trail_id

    add_index :people, :created_by_paper_trail_id
    add_index :people, :updated_by_paper_trail_id

    add_index :race_numbers, :created_by_paper_trail_id
    add_index :race_numbers, :updated_by_paper_trail_id

    add_index :races, :created_by_paper_trail_id
    add_index :races, :updated_by_paper_trail_id

    add_index :refunds, :created_by_paper_trail_id
    add_index :refunds, :updated_by_paper_trail_id

    add_index :teams, :created_by_paper_trail_id
    add_index :teams, :updated_by_paper_trail_id
  end
end
