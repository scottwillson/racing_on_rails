class RemoveSearchResultsLimit < ActiveRecord::Migration
  def change
    change_table :racing_associations do |t|
      t.remove :search_results_limit
    end
  end
end
