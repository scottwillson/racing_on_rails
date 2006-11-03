class MailingListsController < ApplicationController

  model :mailing_list
  session :off

  def app_index
    redirect_to(:controller => "mailing_lists", :action => "index")
  end
  
  def index
    @mailing_lists = MailingList.find_all
  end
end
