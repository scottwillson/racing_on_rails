class RenamePaperTrailVersions < ActiveRecord::Migration[4.2]
  def change
    rename_table :paper_trail_versions, :versions
  end
end
