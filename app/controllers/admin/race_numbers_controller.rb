module Admin
  class RaceNumbersController < Admin::AdminController
    before_filter :require_current_person
    before_filter :require_administrator
  
    def new
      @person = Person.find(params[:person_id])
      @race_number = @person.race_numbers.build
    end
  
    def destroy
      @race_number = RaceNumber.find(params[:id])
      @race_number.destroy
    end
  end
end
