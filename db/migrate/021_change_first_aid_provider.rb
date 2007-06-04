class ChangeFirstAidProvider < ActiveRecord::Migration
  def self.up
    Event.connection.execute('alter table events modify column first_aid_provider varchar(255) default "-------------"')
  end

  def self.down
  end
end
