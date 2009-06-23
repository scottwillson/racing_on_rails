class Admin::BidsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :require_administrator
  layout "admin/application"

  def index
    @bids = Bid.find(:all)
  end
end
