class RenameCreatedBys < ActiveRecord::Migration
  def change
    change_table :discount_codes do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :events do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :people do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :race_numbers do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :races do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :refunds do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end

    change_table :teams do |t|
      t.rename :created_by_paper_trail_id, :created_by_id
      t.rename :created_by_paper_trail_name, :created_by_name
      t.rename :created_by_paper_trail_type, :created_by_type
      t.rename :updated_by_paper_trail_id, :updated_by_id
      t.rename :updated_by_paper_trail_name, :updated_by_name
      t.rename :updated_by_paper_trail_type, :updated_by_type
    end
  end
end
