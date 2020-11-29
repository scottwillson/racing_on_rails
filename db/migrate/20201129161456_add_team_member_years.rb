# frozen_string_literal: true

class AddTeamMemberYears < ActiveRecord::Migration[6.0]
  def up
    add_column :teams, :member_from, :integer, default: nil, null: true, index: true
    add_column :teams, :member_to, :integer, default: nil, null: true, index: true
    execute "update teams set member_from=2020 where member is true"
    execute "update teams set member_to=2020 where member is true"
    remove_column :teams, :member
  end

  def down
    remove_column :teams, :member_from
    remove_column :teams, :member_to
    execute "update teams set member=false where member_from is not nulll"
    add_column :teams, :member, :boolean, default: false, null: false
  end
end
