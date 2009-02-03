class Admin::BidsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :login_required
  layout "admin/application"

  def index
    @bids = Bid.find(:all)
  end
end
