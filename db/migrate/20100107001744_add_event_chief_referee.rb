class AddEventChiefReferee < ActiveRecord::Migration
  def self.up
    add_column :events, :chief_referee, :string, :default => nil, :null => true
    change_column_default :events, :first_aid_provider, nil
  end

  def self.down
    remove_column :events, :chief_referee
    change_column_default :events, :first_aid_provider, "-------------"
  end
end
