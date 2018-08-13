class AddCreatedByPaperTrailName < ActiveRecord::Migration
  def change
    change_table :discount_codes do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :events do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :people do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :race_numbers do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :races do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :refunds do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end

    change_table :teams do |t|
      t.string :created_by_paper_trail_name, default: nil
      t.string :updated_by_paper_trail_name, default: nil
    end
  end
end
