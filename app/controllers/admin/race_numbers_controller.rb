module Admin
  class RaceNumbersController < Admin::AdminController
    def destroy
      @race_number = RaceNumber.find(params[:id])
      @race_number.destroy
    end
  end
end
