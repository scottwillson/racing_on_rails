class CreateEditorRequests < ActiveRecord::Migration
  def self.up
    create_table :editor_requests, :force => true do |t|
      t.integer :lock_version, :null => false, :default => 0
      t.integer :person_id, :null => false, :default => nil
      t.integer :editor_id, :null => false, :default => nil
      t.datetime :expires_at, :null => false
      t.string :token, :null => false
      t.string :email, :null => false
      t.timestamps
    end

    add_index :editor_requests, :editor_id
    add_index :editor_requests, :person_id
    add_index :editor_requests, [ :editor_id, :person_id ], :unique => true
    add_index :editor_requests, :expires_at
    add_index :editor_requests, :token
    
    execute "alter table editor_requests add constraint foreign key (`editor_id`) references `people` (`id`) on delete cascade"
    execute "alter table editor_requests add constraint foreign key (`person_id`) references `people` (`id`) on delete cascade"
  end

  def self.down
    drop_table :editor_requests
  end
end
