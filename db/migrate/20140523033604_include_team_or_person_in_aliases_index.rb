class IncludeTeamOrPersonInAliasesIndex < ActiveRecord::Migration
  def up
    remove_index :aliases, name: "idx_name"

    # Not unique
    add_index :aliases, :name

    add_column :aliases, :aliasable_type, :string, default: nil
    add_index :aliases, :aliasable_type
    add_index :aliases, [ :name, :aliasable_type ], unique: true

    add_column :aliases, :aliasable_id, :integer, default: nil
    add_index :aliases, :aliasable_id

    Alias.transaction do
      Alias.all.each do |a|
        if a.person_id
          Alias.connection.execute "update aliases set aliasable_type='Person',aliasable_id=#{a.person_id} where id=#{a.id}"
        else
          Alias.connection.execute "update aliases set aliasable_type='Team',aliasable_id=#{a.team_id} where id=#{a.id}"
        end
      end
    end

    change_column :aliases, :aliasable_type, :string, default: nil, null: false
    change_column :aliases, :aliasable_id, :integer, default: nil, null: false

    execute "alter table aliases drop foreign key aliases_person_id"
    execute "alter table aliases drop foreign key aliases_team_id_fk"

    remove_column :aliases, :alias
    remove_column :aliases, :person_id
    remove_column :aliases, :team_id
  end

  def down
    remove_index :aliases, :name
    remove_index :name, :aliasable_type
    add_index :aliases, :name, unique: true, name: "idx_name"
  end
end