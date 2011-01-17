module Admin
  class PostsController < Admin::AdminController
    before_filter :require_administrator, :assign_mailing_list
    layout "admin/application"
    
    def index
      @posts = @mailing_list.posts
    end
    
    def new
      @post = @mailing_list.posts.build
      render :edit
    end
    
    def create
      @post = @mailing_list.posts.build(params[:post])
      if @post.save
        flash[:notice] = "Created #{@post.subject}"
        redirect_to edit_admin_mailing_list_post_path(@mailing_list, @post)
      else
        render :edit
      end
    end
    
    def edit
      @post = Post.find(params[:id])
    end
    
    def update
      @post = Post.find(params[:id])
      if @post.update_attributes(params[:post])
        flash[:notice] = "Updated #{@post.subject}"
        redirect_to edit_admin_mailing_list_post_path(@mailing_list, @post)
      else
        render :edit
      end
    end
    
    private
    
    def assign_mailing_list
      @mailing_list = MailingList.find(params[:mailing_list_id])
    end
  end
end
