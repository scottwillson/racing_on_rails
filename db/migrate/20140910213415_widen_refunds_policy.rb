class WidenRefundsPolicy < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA"
      change_column :events, :refund_policy, :text, size: 512
    end
  end

  def down
    if RacingAssociation.current.short_name == "OBRA"
      change_column :events, :refund_policy, :string, size: 256
    end
  end
end
