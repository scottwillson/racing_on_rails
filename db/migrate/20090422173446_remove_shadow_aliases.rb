class Racer < ActiveRecord::Base
end

Alias.class_eval do
  belongs_to :racer, :class_name => "Racer"
end

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
