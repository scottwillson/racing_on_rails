# For testing TableHelper
module Admin
  class TablesController < ActionController::Base
    helper "table"

    attr_accessor :test_assigns
    attr_accessor :inline_template

    def index
      @events = test_assigns
      render :inline => inline_template, :locals => { :controller => self }
    end
  end
end
