class MailingListsController < ApplicationController
  def index
    @mailing_lists = MailingList.find.all()
  end
end
