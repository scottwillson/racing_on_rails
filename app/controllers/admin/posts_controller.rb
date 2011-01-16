module Admin
  class PostsController < Admin::AdminController
    before_filter :require_administrator
    layout "admin/application"
    
    def index
      @mailing_list = MailingList.find(params[:mailing_list_id])
      @posts = @mailing_list.posts
    end
  end
end
