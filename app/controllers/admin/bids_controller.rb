class Admin::BidsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :check_administrator_role
  layout "admin/application"

  def index
    @bids = Bid.find(:all)
  end
end
