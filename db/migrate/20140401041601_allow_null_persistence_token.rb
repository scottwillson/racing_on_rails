class AllowNullPersistenceToken < ActiveRecord::Migration
  def change
    change_column :people, :persistence_token, :string, :null => true, :default => nil
  end
end
