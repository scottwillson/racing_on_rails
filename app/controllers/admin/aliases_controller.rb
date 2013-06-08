module Admin
  class AliasesController < Admin::AdminController
    before_filter :require_administrator
    layout "admin/application"
  
    def destroy
      @alias = Alias.find(params[:id])
      @alias.destroy
    end
  end
end
