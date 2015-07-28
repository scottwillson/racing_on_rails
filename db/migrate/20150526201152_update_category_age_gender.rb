class UpdateCategoryAgeGender < ActiveRecord::Migration
  def change
    Category.reset_column_information
    Category.transaction do
      Category.all.each.with_index do |category, index|
        putc(".") if index % 100 == 0
        category.set_ability_from_name
        category.set_gender_from_name

        if category.parent_id == category.id
          category.parent_id = nil
          puts "Removed circular parent from #{category.name}"
        end

        begin
          category.save!
        rescue ActiveRecord::RecordInvalid => e
          puts "#{category} could not be saved"
          raise e
        end
      end
      puts
    end
  end
end
