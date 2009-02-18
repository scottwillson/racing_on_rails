class CreateRolesUsersJoin < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.column :role_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    admin_role = Role.find_by_name('Administrator')
    
    users = User.find(:all)
    users.each do |user|
      user.roles << admin_role
    end
  end

  def self.down
    drop_table :roles_users
  end
end
