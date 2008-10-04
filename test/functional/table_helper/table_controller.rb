# For testing TableHelper
class TableController < ActionController::Base
  helper "table"
  
  attr_accessor :test_assigns
  attr_accessor :inline_template

  def table
    @events = test_assigns
    render :inline => inline_template
  end
end
