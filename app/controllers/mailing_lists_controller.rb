class MailingListsController < ApplicationController
  def index
    @mailing_lists = MailingList.all
  end
end
