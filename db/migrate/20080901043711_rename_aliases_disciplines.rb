class RenameAliasesDisciplines < ActiveRecord::Migration
  def self.up
    rename_table :aliases_disciplines, :discipline_aliases
  end

  def self.down
    rename_table :discipline_aliases, :aliases_disciplines
  end
end
