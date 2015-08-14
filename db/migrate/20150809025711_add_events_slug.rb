class AddEventsSlug < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :slug, null: true, default: nil
      t.integer :year, null: false, default: nil
      t.index :slug
    end

    Event.find_each do |e|
      e.update_column :year, e.date.year
    end

    add_index :events, [ :year, :slug ], unique: true
    add_index :events, :year
  end
end
