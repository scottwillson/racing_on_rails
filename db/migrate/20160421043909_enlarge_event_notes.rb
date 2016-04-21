class EnlargeEventNotes < ActiveRecord::Migration
  def change
    change_column :events, :notes, :text, limit: 65535, default: nil
  end
end
