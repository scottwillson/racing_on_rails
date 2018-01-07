# frozen_string_literal: true

class WidenRefundsPolicy < ActiveRecord::Migration
  def up
    change_column :events, :refund_policy, :text, size: 512 if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
  end

  def down
    if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
      change_column :events, :refund_policy, :string, size: 256
    end
  end
end
