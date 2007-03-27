class AddMembersOnlyPlace < ActiveRecord::Migration
  def self.up
    add_column :results, :members_only_place, :string, :null => true, :limit => 8
  end

  def self.down
    remove_column :results, :members_only_place
  end
end
