class DefaultRejectedToFalse < ActiveRecord::Migration[5.2]
  def change
    Result.where(rejected: nil).update_all(rejected: false)
    ResultSource.where(rejected: nil).update_all(rejected: false)
    change_column_default :results, :rejected, from: nil, to: false
    change_column_default :result_sources, :rejected, from: nil, to: false
    change_column_null :results, :rejected, false
    change_column_null :result_sources, :rejected, false
  end
end
