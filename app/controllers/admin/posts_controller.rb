module Admin
  class PostsController < Admin::AdminController
    before_filter :require_administrator
    layout "admin/application"
    
    def index
      @mailing_list = MailingList.find(params[:mailing_list_id])
      @posts = @mailing_list.posts
    end
    
    def new
      @mailing_list = MailingList.find(params[:mailing_list_id])
      @post = @mailing_list.posts.build
      render :edit
    end
    
    def create
      @mailing_list = MailingList.find(params[:mailing_list_id])
      @post = @mailing_list.posts.build(params[:post])
      if @post.save
        redirect_to edit_admin_mailing_list_post_path(@mailing_list, @post)
      else
        render :edit
      end
    end
  end
end
