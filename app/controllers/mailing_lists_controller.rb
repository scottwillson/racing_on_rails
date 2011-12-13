class MailingListsController < ApplicationController
  def index
    @mailing_lists = MailingList.all
  end

  def confirm
    @mailing_list = MailingList.find(params[:mailing_list_id])
  end
  
  def confirm_private_reply
    @mailing_list = MailingList.find(params[:mailing_list_id])
  end
end
