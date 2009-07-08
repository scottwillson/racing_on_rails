# Some old events in DB are missing disciplines
class EnsureEventDiscipline < ActiveRecord::Migration
  def self.up
    execute "update events set discipline = 'Road' where discipline is null or discipline = ''"
  end
end
