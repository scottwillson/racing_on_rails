class ChangePersonWantsMailDefaultToFalse < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.change_default :wants_mail, false
      t.change_default :wants_email, false
    end
  end

  def self.down
    change_table :people do |t|
      t.change_default :wants_mail, true
      t.change_default :wants_email, true
    end
  end
end
