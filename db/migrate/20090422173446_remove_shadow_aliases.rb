# After switch to UTF-8, MySQL may consider some Aliases as exact matches the Racer or Team names
class RemoveShadowAliases < ActiveRecord::Migration
  def self.up
    Alias.find(:all).each do |a|
      if (a.team && Team.exists?(['name = ?', a.name])) || (a.racer && Racer.exists?(["trim(concat(first_name, ' ', last_name)) = ?", a.name]))
        say a.name
        a.destroy
      end
    end
  end

  def self.down
  end
end
