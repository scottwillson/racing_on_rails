class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end
    Role.create(:name => 'Administrator')
    Role.create(:name => 'Member')
  end

  def self.down
    drop_table :roles
  end
end
