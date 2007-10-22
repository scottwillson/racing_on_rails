class MailingListsController < ApplicationController
  session :off

  def index
    @mailing_lists = MailingList.find(:all)
  end
end
