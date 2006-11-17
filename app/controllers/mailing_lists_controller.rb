class MailingListsController < ApplicationController

  model :mailing_list
  session :off

  def index
    @mailing_lists = MailingList.find_all
  end
end
