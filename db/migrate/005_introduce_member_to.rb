class IntroduceMemberTo < ActiveRecord::Migration
 def self.up
   add_column(:racers, :member_to, :date)
   rename_column(:racers, :member_on, :member_from)
   Racer.connection.execute("update racers set member_to='2006-12-31' where member is true")
   Racer.connection.execute("update racers set member_from='2006-01-01' where member is true and member_from is null")
   Racer.connection.execute("update racers set member_to='2005-12-31' where member is false and member_from is not null")
   Racer.connection.execute("update racers set member_to=null where member is false and member_from is null")
   remove_column(:racers, :member)
 end
end