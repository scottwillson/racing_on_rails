class Admin::BidsController < Admin::RecordEditor

  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  edits :bid

  def index
    @bids = Bid.find(:all)
  end
end
