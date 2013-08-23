class CreateHomes < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.belongs_to :photo

      t.timestamps
    end
  end
end
