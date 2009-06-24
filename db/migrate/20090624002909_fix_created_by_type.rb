class FixCreatedByType < ActiveRecord::Migration
  def self.up
    execute "update people set created_by_type='Person' where created_by_type='User'"
    execute "update teams set created_by_type='Person' where created_by_type='User'"
  end
end
