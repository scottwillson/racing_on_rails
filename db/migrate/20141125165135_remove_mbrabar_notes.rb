class RemoveMbrabarNotes < ActiveRecord::Migration
  def change
    bar = Competitions::MbraBar.current_year.first
    if bar
      bar.races.map(&:results).flatten.each do |result|
        if result.notes.present?
          result.update_attributes! notes: nil
        end
      end
    end
  end
end
