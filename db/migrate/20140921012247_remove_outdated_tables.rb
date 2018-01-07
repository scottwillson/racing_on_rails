# frozen_string_literal: true

class RemoveOutdatedTables < ActiveRecord::Migration
  def change
    begin
      remove_column(:people, :fullname)
    rescue StandardError
      nil
    end

    %w[ duplicates_racers engine_schema_info historical_names images news_items promoters racers standings users ].each do |name|
      drop_table name if table_exists?(name)
    end
  end
end
