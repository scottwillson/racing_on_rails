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
  end
end
