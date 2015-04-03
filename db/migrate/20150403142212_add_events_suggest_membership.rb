class AddEventsSuggestMembership < ActiveRecord::Migration
  def change
    add_column :events, :suggest_membership, :boolean, default: true, null: false
  end
end