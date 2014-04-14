class AddRacingAssociationResultQuestionsUrl < ActiveRecord::Migration
  def change
    add_column :racing_associations, :result_questions_url, :string, default: nil
    if RacingAssociation.current.short_name == "OBRA"
      execute "update racing_associations set result_questions_url = 'http://www.obra.org/results/questions.html'"
    end
  end
end
