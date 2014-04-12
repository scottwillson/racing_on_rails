class Expand < ActiveRecord::Migration
  def change
    change_column :events, :type, :string, limit: 255
  end
end
